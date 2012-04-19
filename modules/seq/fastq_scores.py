#!/usr/bin/python -tt

description='''
Generate quality control reports regarding the fastq
quality scores for fastq data.

Outputs:
    $PREFIX-qscore-pos-avgs.txt
    $PREFIX-qscore-cumulative-distrib.txt

 Supported fastq file types: 
    phred
    fastq-sanger (old solexa/early illumina)
    fastq-illumina (newer Illumina 1.3 to 1.7 style)
'''

import argparse
import numpy
import sys
from Bio import SeqIO
#import jjinking.fnc.filesys as jfs

# Platform to code mapping
_PLATFORM_TYPE = {}
_PLATFORM_TYPE['qual'] = 0 # Regular phred scores, no offset
_PLATFORM_TYPE['fastq-sanger'] = 1 # Phred scores with ASCII offset 33
_PLATFORM_TYPE['fastq-illumina'] = 2 # Phred scores with ASCII offset 64

# Generate reverse-lookup
_CODE2PLATFORM = {}
for k,v in _PLATFORM_TYPE.items():
    _CODE2PLATFORM[v] = k

# Phred score ranges
_MIN_PHRED_SCORE = 0
_MAX_PHRED_SCORE = 40

def pos_avg(sums, counts):
    '''
    Take the positional average of sums and counts, which are numpy arrays
    Return a single array containing positional averages.
    '''

    if len(sums) != len(counts):
        sys.stderr.write('Error computing average quality score for multiple fastqfiles: Unmatching sums length and sums counts\n')
        exit(1)

    avgs = numpy.array([])
    for i in range(len(sums)):
        avg = float(sums[i]) / counts[i]
        avgs = numpy.append(avgs, avg)
    return avgs

def add_zero_padded(scores, sums, counts):
    '''
    The lengths of the two arrays can be different, so the arrays are resized with zero pads
    '''
    len_scores = len(scores)
    len_sums = len(sums)

    # If the lengths of scores and sums are equal
    if len_scores == len_sums:
        sums = sums + scores
        counts = counts + numpy.ones(len_scores, dtype=numpy.int)
    # If less than
    elif len_scores < len_sums:
        diff_ = len_sums - len_scores
        sums = sums + numpy.append(scores, numpy.zeros(diff_, dtype=numpy.int))
        counts = counts + numpy.append(numpy.ones(len_scores, dtype=numpy.int), numpy.zeros(diff_, dtype=numpy.int))
    # If greater than
    else: # len_scores > len_sums
        diff_ = len_scores - len_sums
        sums = numpy.append(sums, numpy.zeros(diff_, dtype=numpy.int)) + scores
        counts = numpy.append(counts, numpy.zeros(diff_, dtype=numpy.int)) + numpy.ones(len_scores, dtype=numpy.int)
    return sums, counts

def generate_cumul_distrib(scores2counts):
    all_scores = scores2counts.keys()
    scores_min = int(min(all_scores))
    scores_max = int(max(all_scores))
    cumul = []
    running_sum = 0
    for s in range(_MIN_PHRED_SCORE, _MAX_PHRED_SCORE + 1):
        if s in scores2counts:
            running_sum += scores2counts[s]
        cumul.append(running_sum)
    # Find percentage distrib by dividing by the total sum
    running_sum = float(running_sum)
    for i in range(len(cumul)):
        cumul[i] = 100.0 * cumul[i] / running_sum
    return cumul

def update_score_counts(scoreslist, scores2counts):
    for s in scoreslist:
        if s in scores2counts:
            scores2counts[s] += 1
        else:
            scores2counts[s] = 1

def fastq_scores_report(fastqfile, platform=_PLATFORM_TYPE['fastq-illumina']):
    '''
    Read a fastq file, and return the positional sums, counts, averages, and score counts
    '''
    # Get the phred score offset value
    qscore_offset = 0
    if platform == _PLATFORM_TYPE['fastq-sanger']:
        qscore_offset = 33
    elif platform == _PLATFORM_TYPE['fastq-illumina']:
        qscore_offset = 64

    # Set up counting for cumulative distribution
    scores2counts = {}
    
    # Set up vars to accumulate positional sums and averages
    sums = numpy.array([])
    counts = numpy.array([])

    # Read the fastq file
    file_ext = fastqfile.split('.')[-1]
    if file_ext == 'gz':
        import gzip
        f = gzip.GzipFile(fastqfile, 'r')
    elif file_ext == 'zip':
        import zipfile
        f = zipfile.ZipFile(fastqfile, 'r')
    else:
        f = open(fastqfile, 'r')

    line_count = 0
    for line in f:
        record_row = line_count % 4
        line = line.strip()
        
        # If it's a quality score row
        if record_row == 3:
            # Convert qscore string to an array of phred scores
            scores_list = []
            for s in line:
                scores_list.append(ord(s) - qscore_offset)
            scores = numpy.array(scores_list)

            # Update the positional sums and counts
            sums, counts = add_zero_padded(scores, sums, counts)

            # Update the counts of the individual scores
            update_score_counts(scores_list, scores2counts)

        line_count += 1
    f.close()

    # Check to make sure that the length of sums and counts are equal
    if len(sums) != len(counts):
        sys.stderr.write('Error computing average quality score for fastqfile: Unmatching sums length and sums counts in %s\n' % fastqfile)
        exit(1)

    # Compute the cumulative distribution of the scores
    cumul_distrib = generate_cumul_distrib(scores2counts)

    # Compute the positional averages
    avgs = pos_avg(sums, counts)

    return sums, counts, avgs, cumul_distrib

def num2str(array_):
    '''
    Convert a numpy array to string
    '''
    return [str(s)  for s in array_]

def main():
    # Set up command line args
    ap = argparse.ArgumentParser(description=description)
    # Required
    ap.add_argument('fastqfile',
                    help='Fastq file')
    # Optional
    ap.add_argument('-t', '--platform-type',
                    help='\n'.join(['0: Phred scores;',
                                    '1: fastq-sanger, Phred with ASCII offset 33;',
                                    '2(default): fastq-illumina, Phred with ASCII offset 64']),
                    type=int,
                    choices=range(3),
                    default=_PLATFORM_TYPE['fastq-illumina'])
    ap.add_argument('-o', '--out-prefix',
                    help='Output prefix.  All output files will be prefixed by this parameter',
                    type=str)
    params = ap.parse_args()

    # Output filenames
    out_prefix = params.fastqfile
    if params.out_prefix:
        out_prefix = params.out_prefix

    # Output column header
    #label = params.fastqfile.replace('.fastq','')
    label = params.fastqfile

    # Compute the quality score reports
    sums, counts, avgs, cumul_distrib = fastq_scores_report(params.fastqfile, params.platform_type)

    # Output to files
    pos_avg_outstr = '%s\n' % (label + '\t' + '\t'.join(num2str(avgs)))
    cum_dis_outstr = '%s\n' % (label + '\t' + '\t'.join(num2str(cumul_distrib)))
    fo_avg = open('.'.join([out_prefix, 'qscore.avgs.txt']),'w')
    fo_avg.write(pos_avg_outstr)
    fo_avg.close()
    fo_cum = open('.'.join([out_prefix, 'qscore.cdf.txt']),'w')
    fo_cum.write(cum_dis_outstr)
    fo_cum.close()
    
    
if __name__ == '__main__':
    main()
