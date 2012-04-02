#!/usr/bin/env python

description = '''
Read in a fastq file and generate stats about the sequences
Output the stats in human readable form, and xml format
'''

import argparse
import sys
from ngs import filesys, seq

def main():
    # Set up command line arguments
    ap = argparse.ArgumentParser(description=description)
    # Required args
    ap.add_argument('fastqfile', 
                    help='Fastq file containing the sequence records.  May be zipped or gzipped (must have correct extension, i.e. .zip, .gz)')
    # Optional args
    ap.add_argument('-o', '--out-prefix', 
                    help='Output files\' prefix')
    params = ap.parse_args()

    # Set up output filenames
    out_prefix = params.fastqfile
    if params.out_prefix:
        out_prefix = params.out_prefix
    # Output xml filename
    outfilename_xml = '.'.join([out_prefix, 'fastq_stats', 'xml'])
    # Output human-readable filename
    outfilename_txt = '.'.join([out_prefix, 'fastq_stats', 'txt'])

    # Get handle for reading flat, gzipped or zipped fastq file
    fastq_handle = filesys.get_file_read_handle(params.fastqfile)
    # Generate stats
    readcount, basecount, length_hist = seq.fastq_seq_stats(fastq_handle)

    # Output xml
    stats_xml = seq.seqstats2xml(readcount, basecount, length_hist)
    f = open(outfilename_xml, 'w')
    f.write(stats_xml)
    f.close()

    # Output human-readable text
    f = open(outfilename_txt, 'w')
    stats_txt = "Readcount:\t%i\nBasecount:\t%i\n\nLength Histogram: \n%s"
    f.close()
    
        

if __name__ == '__main__':
    main()
