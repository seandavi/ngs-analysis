#!/usr/bin/env python
description = '''
Read in a maf file and generate summaries
Summaries are pos-based or gene-based
'''

import argparse
import sys
from ngs import maf

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('maf_file',
                    help='Input maf file',
                    nargs='?',
                    type=maf.MafFile,
                    default=sys.stdin)
    ap.add_argument('-t', '--type',
                    help='Type of summary to generate',
                    choices=['pos_simple','pos_detailed','gene'],
                    default='gene')
    ap.add_argument('-o', '--outfile',
                    help='Name of output file  (default stdout)',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()

    if params.type == 'pos_simple':
        params.maf_file.generate_pos_report(fout=params.outfile, detailed=False)
    elif params.type == 'pos_detailed':
        params.maf_file.generate_pos_report(fout=params.outfile, detailed=True)
    elif params.type == 'gene':
        params.maf_file.generate_gene_report(fout=params.outfile)


if __name__ == '__main__':
    main()
