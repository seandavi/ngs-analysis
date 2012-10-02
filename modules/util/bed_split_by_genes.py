#!/usr/bin/env python
description = '''
Read in a bed file, and create a file for every single line in the bed file.
Name the file according to the 4th column of the bed file, which is usually
the gene name.
'''

import argparse
import os
import sys

def main():
    # Set up cli argument options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('bed_file', 
                    help='Input bed file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-o', '--outputdir',
                    help='Output directory',
                    type=str,
                    default='.')
    params = ap.parse_args()

    # Create directory if it doesn't exist
    if not os.path.isdir(params.outputdir):
        os.makedirs(params.outputdir)

    # Read bed file and create individual files for each line
    with params.bed_file:
        for line in params.bed_file:
            cols = line.strip().split('\t')
            outfile_name = cols[3]
            with open(os.path.join(params.outputdir, outfile_name), 'a') as fo:
                fo.write(line)


if __name__ == '__main__':
    main()
