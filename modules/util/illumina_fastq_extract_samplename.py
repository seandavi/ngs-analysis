#!/usr/bin/env python

description = '''
Given a filename in the format of Illumina Hiseq output fastq files,
extract the sample name prefix.

i.e. foo_AAAAAA_L00N_R1_001.fastq.gz  ==>  foo
'''

import argparse
import re
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('fastq_file',
                    help='Illumina fastq file',
                    type=str)
    params = ap.parse_args()

    match = re.search(r'(.+)_[ACGT]{6}_L\d{3}_R[12]_\d{3}\.fastq\.gz', params.fastq_file)

    if not match:
        sys.stderr.write('No sample name found.  Please check to make sure that the file name is correct.\n')
        sys.exit(1)
    
    sys.stdout.write(match.group(1))


if __name__ == '__main__':
    main()
