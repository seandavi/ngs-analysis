#!/usr/bin/env python
description = '''
Read in a bed file and generate a list of the lengths for each region (4th column)
This tool assumes that the bedfile has already been merged (no overlapping regions)

I.e. If a bedfile contains the following rows:
chr1 0   10  geneA
chr1 50  200 geneA
chr2 100 200 geneB

The output will be:
geneA 160
geneB 100
'''

import argparse
import pickle
import sys
from collections import defaultdict
from ngs import util

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('bedfile', 
                    help='Input bed format file',
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    ap.add_argument('-o', '--out-format',
                    help='Output format',
                    choices=['xml','tsv', 'pkl'],
                    default='pkl')
    params = ap.parse_args()

    g2l = defaultdict(int)
    with params.bedfile as f:
        for line in f:
            la = line.strip().split()
            g2l[la[3]] += int(la[2]) - int(la[1])

    # Output results
    if params.out_format == 'tsv':
        for g,l in g2l.iteritems():
            sys.stdout.write('%s\t%s\n' % (g,l))
    # Output in xml format
    elif params.out_format == 'xml':
        sys.stdout.write(util.dict2xml(g2l))
    # Output in pickle format
    else:
        pickle.dump(g2l, sys.stdout, pickle.HIGHEST_PROTOCOL)
        

if __name__ == '__main__':
    main()
