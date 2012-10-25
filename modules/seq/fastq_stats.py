#!/usr/bin/env python

description = '''
Read in a fastq file and generate stats about the sequences
Output the stats in human readable form, and xml format
'''

import argparse
import sys
from ngs import seq

def main():
    # Set up command line arguments
    ap = argparse.ArgumentParser(description=description)
    # Required args
    ap.add_argument('fastqfile', 
                    help='Fastq file containing the sequence records.  May be plain text, zipped, or gzipped (must have correct extension, i.e. .zip, .gz)')
    # Optional args
    ap.add_argument('-o', '--out-prefix', 
                    help='Output files\' prefix')
    params = ap.parse_args()

    # Set up output filenames
    out_prefix = params.fastqfile
    if params.out_prefix:
        out_prefix = params.out_prefix

    # Output xml filename
    outfilename_xml = '.'.join([out_prefix, 'seqstat', 'xml'])
    # Output human-readable filename
    outfilename_txt = '.'.join([out_prefix, 'seqstat', 'txt'])

    # Generate stats
    fastqstats = seq.FastqStats(params.fastqfile)
    fastqstats.get_seqstats()

    # Output xml
    f = open(outfilename_xml, 'w')
    f.write(fastqstats.seqstats2xml())
    f.close()

    # Output txt
    f = open(outfilename_txt, 'w')
    f.write(fastqstats.seqstats2txt())
    f.close()


if __name__ == '__main__':
    main()
