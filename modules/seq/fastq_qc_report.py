#!/usr/bin/env python
description = '''
Generate a fastqc report using fastqc output images and data in pdf format
'''

import argparse
import logging
import os
import re
import sys
import StringIO
from django.conf import settings
from django.template import Template, Context, Library, builtins
from xhtml2pdf import pisa

#=================================#
# Custom template filters
register = Library()

@register.filter
def keyval(dict, key):
    return dict[key]

builtins.append(register)
    
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
        image_title = ' '.join([w[0].upper() + w[1:] for w in imagef.split('.')[0].split('_')])
        data.setdefault('images', {}).setdefault(sample, {}).setdefault(image_title, {})[read] = path2file

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

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('template',
                    help='Template file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('sample_dirs',
                    help='Sample directories',
                    nargs='+',
                    type=str)
    ap.add_argument('-c', '--company-name',
                    help='Name of company providing the sequence report',
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

    # Set the company name
    data['company'] = ' '.join(params.company_name)

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
        r1_filesize = os.path.getsize(os.path.join(sample_dir, data_sample['Filename'][READ_NUM['R1']]))
        r2_filesize = os.path.getsize(os.path.join(sample_dir, data_sample['Filename'][READ_NUM['R2']]))
        data_sample.setdefault('Filesize', {})[READ_NUM['R1']] = ' '.join([str(r1_filesize), 'bytes'])
        data_sample.setdefault('Filesize', {})[READ_NUM['R2']] = ' '.join([str(r2_filesize), 'bytes'])

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
