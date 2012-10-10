#!/usr/bin/env python
description = '''
Generate a fastqc report using fastqc output images and data in pdf format
'''

import argparse
import glob
import logging
import os
import re
import sys
import StringIO
from BeautifulSoup import BeautifulSoup
from collections import defaultdict
from django.conf import settings
from django.template import Template, Context, Library, builtins
from django.utils.encoding import force_unicode
from xhtml2pdf import pisa
from ngs import fastq

#=================================#
# Custom template filters
register = Library()

@register.filter
def keyval(d, key):
    return d.get(key,'')
builtins.append(register)

@register.filter(is_safe=True)
def intcomma(value, use_l10n=True):
    """
    Converts an integer to a string containing commas every three digits.
    For example, 3000 becomes '3,000' and 45000 becomes '45,000'.
    """
    if settings.USE_L10N and use_l10n:
        try:
            if not isinstance(value, float):
                value = int(value)
        except (TypeError, ValueError):
            return intcomma(value, False)
        else:
            return number_format(value, force_grouping=True)
    orig = force_unicode(value)
    new = re.sub("^(-?\d+)(\d{3})", '\g<1>,\g<2>', orig)
    if orig == new:
        return new
    else:
        return intcomma(new, use_l10n)
                
@register.filter
def fastqc_context2title_text(value):
    '''
    Given a keyword for each fastqc context, return the context text
    so that it can be displayed as a title
    '''
    return {'basic_statistics': 'Basic Statistics',
            'per_base_quality': 'Per Base Quality',
            'per_sequence_quality': 'Per Sequence Quality',
            'per_base_sequence_content': 'Per Base Sequence Content',
            'per_base_gc_content': 'Per Base GC Content',
            'per_sequence_gc_content': 'Per Sequence GC Content',
            'per_base_n_content': 'Per Base N Content',
            'sequence_length_distribution': 'Sequence Length Distribution',
            'duplication_levels': 'Duplication Levels',
            'overrepresented_sequences': 'Overrepresented Sequences',
            'kmer_profiles': 'Kmer Content'}.setdefault(value,'')
    
@register.filter
def fastqc_context2summary_text(value):
    '''
    Map context keyword for each fastqc plot to their corresponding term used
    in the summary file
    '''
    return {'basic_statistics': 'Basic Statistics',
            'per_base_quality': 'Per base sequence quality',
            'per_sequence_quality': 'Per sequence quality scores',
            'per_base_sequence_content': 'Per base sequence content',
            'per_base_gc_content': 'Per base GC content',
            'per_sequence_gc_content': 'Per sequence GC content',
            'per_base_n_content': 'Per base N content',
            'sequence_length_distribution': 'Sequence Length Distribution',
            'duplication_levels': 'Sequence Duplication Levels',
            'overrepresented_sequences': 'Overrepresented Sequences',
            'kmer_profiles': 'Kmer Content'}.setdefault(value,'')

#=================================#

READ_NUM = {
    'R1': 'R1',
    'R2': 'R2'
    }

def load_fastqc_summary(data, summaryfile, sample, read=READ_NUM['R1']):
    '''
    Load fastqc summary.txt contents into data
    data
      summary
        sample
          qc_type
            read
              status
    '''
    qc_types = []
    with open(summaryfile, 'r') as f:
        for line in f:
            la = line.strip().split('\t')
            status = la[0]
            qc_type = la[1]
            qc_types.append(qc_type)
            data.setdefault('summary', {}).setdefault(sample, {}).setdefault(qc_type, {})[read] = status
    data['qc_types'] = qc_types

def load_fastqc_data(data, datafile, sample, read=READ_NUM['R1']):
    '''
    Given a fastqc_data.txt file, read the data and enter the
    key,value pairs into the data dictionary
    data
      data
        sample
          key
            read
              val
    '''
    with open(datafile, 'r') as f:
        for line in f:
            la = line.strip().split('\t')
            if len(la) > 1:
                k = la[0]
                v = la[1]
                if k == 'Filename':
                    k = 'FastqFilename'
                data.setdefault('data', {}).setdefault(sample, {}).setdefault(k, {})[read] = v

def load_fastqc_images(data, imagedir, sample, read=READ_NUM['R1']):
    '''
    Load all the fastqc images in the image directory
    data
      images
        sample
          title
            read
              imagefilepath
    '''
    imagefiles = os.listdir(imagedir)
    for imagef in imagefiles:
        if not imagef.endswith('.png'):
            continue
        path2file = os.path.join(imagedir, imagef)
        image_title = imagef.split('.')[0]
        data.setdefault('images', {}).setdefault(sample, {}).setdefault(image_title, {})[read] = path2file

def load_fastqc_example_images(appendix_example_fastqc, imagedir, example_type='good'):
    '''
    Load all the fastqc images in the image directory
    '''
    imagefiles = os.listdir(imagedir)
    for imagef in imagefiles:
        if not imagef.endswith('.png'):
            continue
        path2file = os.path.join(imagedir, imagef)
        image_title = imagef.split('.')[0]
        appendix_example_fastqc.setdefault(image_title, {})[example_type] = path2file

def find_fastqc_dirs(sample_dir):
    '''
    Given a sample directory resulting from CASAVA basecalling,
    find and return the fastqc directory names
    '''
    if not os.path.isdir(sample_dir):
        sys.stderr.write('Could not find directory %s\nExiting.\n\n' % sample_dir)
        sys.exit(1)

    fastqc_dir_R1 = None
    fastqc_dir_R2 = None
    for f in os.listdir(sample_dir):
        if re.search(r'.+_[ACGT]+_L[0-9]+_R1_[0-9]+_fastqc$', f):
            fastqc_dir_R1 = os.path.join(sample_dir, f)
        elif re.search(r'.+_[ACGT]+_L[0-9]+_R2_[0-9]+_fastqc$', f):
            fastqc_dir_R2 = os.path.join(sample_dir, f)
    if fastqc_dir_R1 is None and fastqc_dir_R2 is None:
        sys.stderr.write('Could not find any fastqc directories. Exiting.\n\n')
        sys.exit(1)
    elif fastqc_dir_R1 is None:
        sys.stderr.write('Could not find fastqc directory for read 1. Exiting.\n\n')
        sys.exit(1)
    elif fastqc_dir_R2 is None:
        sys.stderr.write('Could not find fastqc directory for read 2. Exiting.\n\n')
        sys.exit(1)
    return fastqc_dir_R1, fastqc_dir_R2

def humanize_bytes(bytes, precision=1):
        """
        Return a humanized string representation of a number of bytes.
        """
        bytes = float(bytes)
        
        abbrevs = (
            (1<<50L, 'PB'),
            (1<<40L, 'TB'),
            (1<<30L, 'GB'),
            (1<<20L, 'MB'),
            (1<<10L, 'kB'),
            (1, 'bytes')
            )
        if bytes == 1:
            return '1 byte'
        for factor, suffix in abbrevs:
            if bytes >= factor:
                break
        return '%.*f %s' % (precision, bytes / factor, suffix)

def parse_demultiplex_stats_file(demul_stats_htm):
    '''
    Load and parse Illumina Demultiplex_Stats.htm
    '''
    with open(demul_stats_htm, 'r') as f:
        soup = BeautifulSoup(f.read())
    table = soup.find("div", {"id" : "ScrollableTableBodyDiv"}).find("table")
    sample2field2val = defaultdict(dict)
    for i,row in enumerate(table.findAll('tr')):
        col = row.findAll('td')
        sampleID = col[1].string.strip()
        gt_Q30 = col[13].string.strip()
        mean_Q = col[14].string.strip()
        sample2field2val[sampleID]['gt_Q30'] = gt_Q30
        sample2field2val[sampleID]['mean_Q'] = mean_Q
    return sample2field2val

def load_adapter_file(adapter_filein):
    '''
    Given handle to the adpater file, read in the adapter sequences
    Input file format:
    Header lines describing the universal adapter prefixed with ##
    Column names line following the header lines prefixed with #
    
    3 tabbed-delimited columns
    column 1: index number
    column 2: barcode sequence
    column 3: adapter sequence
    '''
    barcode2index = {}
    
    description_texts = []
    colnames = None
    index_barcode_adapters = []
    with adapter_filein:
        for line in adapter_filein:
            line = line.strip('\n')
            # If header lines
            if re.match('##', line):
                description_texts.append(line[2:])
                continue

            # If column header line
            if re.match('#', line):
                colnames = line[1:].split('\t')
                continue

            # Append adapter rows
            cols = line.split('\t')
            index_barcode_adapters.append((cols[0],
                                        cols[1],
                                        cols[2]))
            barcode2index[cols[1]] = cols[0]
    return barcode2index, description_texts, colnames, index_barcode_adapters

def load_passfail_descriptions(fin):
    '''
    Read in pass/fail standards described in fastqc manual for each plot
    Format:

    Header line containing column names
    
    3 tab-delimited columns
    column 1: name of plot type
    column 2: warning description
    column 3: fail description

    Output a dictionary mapping plot name:(warning|fail):description text
    '''
    name2warnfail2text = defaultdict(dict)
    with fin:

        # Skip header line
        fin.next()
        
        for line in fin:
            cols = line.strip().split('\t')
            plotname = cols[0]
            warntext = cols[1]
            failtext = cols[2]
            name2warnfail2text[plotname]['warn'] = warntext
            name2warnfail2text[plotname]['fail'] = failtext
    return name2warnfail2text

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('template',
                    help='Template file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('adapter_file',
                    help='Adapter sequences file (in specified format)',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('example_good_dir',
                    help='Fastqc image directory containing good quality result image files',
                    type=str)
    ap.add_argument('example_bad_dir',
                    help='Fastqc image directory containing bad quality result image files',
                    type=str)
    ap.add_argument('pass_fail_descriptions',
                    help='Description of the pass/fail standards for the fastqc plots (in specified format)',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('sample_dirs',
                    help='Sample directories',
                    nargs='+',
                    type=str)
    ap.add_argument('-t', '--title',
                    help='Title of the Report',
                    nargs="*",
                    default=['Sequencing', 'Service', 'Center'])
    ap.add_argument('-o', '--outfile',
                    help='Output pdf filename',
                    type=argparse.FileType('w'),
                    default=open('fastq.qc.report.pdf','w'))
    params = ap.parse_args()

    # Set dependent modules' settings
    logging.basicConfig()
    settings.configure()

    # Load template file
    t = Template(params.template.read())
    data = {}

    # Set the report title
    data['title'] = ' '.join(params.title)

    # Load the adapter file
    barcode2index, descriptions, colheaders, adapters = load_adapter_file(params.adapter_file)
    data.setdefault('appendix', {}).setdefault('adapter', {})['descriptions'] = descriptions
    data['appendix']['adapter']['colheaders'] = colheaders
    data['appendix']['adapter']['adapters'] = adapters

    # Load the pass_fail descriptions
    data['appendix']['qc_standards'] = load_passfail_descriptions(params.pass_fail_descriptions)

    # Load example fastqc images
    data_appendix_example_fastqc = data['appendix'].setdefault('example_fastqc', {})
    load_fastqc_example_images(data_appendix_example_fastqc, params.example_good_dir, example_type='good')
    load_fastqc_example_images(data_appendix_example_fastqc, params.example_bad_dir, example_type='bad')

    # Load and parse the demultiplex_stats file
    demultiplex_stats_file = glob.glob(params.sample_dirs[0] + '/../../Basecall_Stats_*/Demultiplex_Stats.htm')[0]
    sample2field2val = parse_demultiplex_stats_file(demultiplex_stats_file)

    # Loop through each sample directory and load data
    samples = []
    for sample_dir in params.sample_dirs:
        sample = sample_dir.replace('Sample_', '')
        samples.append(sample)

        # Locate the fastqc directory for file
        fastqc_R1_dir, fastqc_R2_dir = find_fastqc_dirs(sample_dir)

        # Load the summary.txt data
        fastqc_summary_file_R1 = os.path.join(fastqc_R1_dir, 'summary.txt')
        fastqc_summary_file_R2 = os.path.join(fastqc_R2_dir, 'summary.txt')
        load_fastqc_summary(data, fastqc_summary_file_R1, sample, read=READ_NUM['R1'])
        load_fastqc_summary(data, fastqc_summary_file_R2, sample, read=READ_NUM['R2'])

        # Load fastqc data
        r1_datafile = os.path.join(fastqc_R1_dir, 'fastqc_data.txt')
        r2_datafile = os.path.join(fastqc_R2_dir, 'fastqc_data.txt')
        load_fastqc_data(data, r1_datafile, sample, read=READ_NUM['R1'])
        load_fastqc_data(data, r2_datafile, sample, read=READ_NUM['R2'])

        # Get the filesizes
        data_sample = data['data'][sample]
        r1_fastqfile = os.path.join(sample_dir, data_sample['FastqFilename'][READ_NUM['R1']])
        r2_fastqfile = os.path.join(sample_dir, data_sample['FastqFilename'][READ_NUM['R2']])
        r1_fastqfilesize = str(os.path.getsize(r1_fastqfile))
        r2_fastqfilesize = str(os.path.getsize(r2_fastqfile))
        data_sample.setdefault('FastqFilesize', {})[READ_NUM['R1']] = humanize_bytes(r1_fastqfilesize)
        data_sample.setdefault('FastqFilesize', {})[READ_NUM['R2']] = humanize_bytes(r2_fastqfilesize)
        # Check if md5 is made, and append that data
        data_sample.setdefault('MD5Filename', {})
        data_sample['MD5Filename'][READ_NUM['R1']] = data_sample['FastqFilename'][READ_NUM['R1']] + '.MD5'
        data_sample['MD5Filename'][READ_NUM['R2']] = data_sample['FastqFilename'][READ_NUM['R2']] + '.MD5'
        r1_md5file = r1_fastqfile + '.MD5'
        r2_md5file = r2_fastqfile + '.MD5'
        if os.path.exists(r1_md5file) and os.path.exists(r2_md5file):
            r1_md5filesize = str(os.path.getsize(r1_md5file))
            r2_md5filesize = str(os.path.getsize(r2_md5file))
            data_sample.setdefault('MD5Filesize', {})[READ_NUM['R1']] = humanize_bytes(r1_md5filesize)
            data_sample.setdefault('MD5Filesize', {})[READ_NUM['R2']] = humanize_bytes(r2_md5filesize)


        # Sequence summary
        r1_fastqfile_fields = fastq.IlluminaFastqFile.parse_filename(data_sample['FastqFilename'][READ_NUM['R1']])
        r1_index = r1_fastqfile_fields.barcode
        data.setdefault('seqsum', {}).setdefault(sample, {})
        seqsum_sample = data['seqsum'][sample]
        seqsum_sample['barcode'] = r1_index
        seqsum_sample['barcode_index'] = barcode2index[r1_index]
        seqsum_sample['reads'] = int(data['data'][sample]['Total Sequences']['R1']) * int(data['data'][sample]['Sequence length']['R1'])
        seqsum_sample['gt_Q30'] = sample2field2val[sample]['gt_Q30']
        seqsum_sample['mean_Q'] = sample2field2val[sample]['mean_Q']
        

        # Load the images
        r1_imagedir = os.path.join(fastqc_R1_dir, 'Images')
        r2_imagedir = os.path.join(fastqc_R2_dir, 'Images')
        load_fastqc_images(data, r1_imagedir, sample, read=READ_NUM['R1'])
        load_fastqc_images(data, r2_imagedir, sample, read=READ_NUM['R2'])
        
    data['samples'] = samples
    
    # Generate html
    c = Context(data)
    html = t.render(c)

    # Convert to pdf
    pdf = pisa.pisaDocument(StringIO.StringIO(html.encode("ISO-8859-1")), params.outfile)
    if pdf.err:
        sys.stderr.write('Error converting to pdf\n')
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
