#!/usr/bin/env python
description = '''
Read in UCSC\'s dbsnp flat file and generate a dictionary mapping
chromosome, position(0-based), ref allele, alt allele tuple to rsid.
Note: chromosome contains only the numbers, not the \'chr\' prefix.
'''

import argparse
import cPickle
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('infile',
                    help='dbsnp text flat file, i.e. snp135.txt',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('outfile',
                    help='Output .pkl file',
                    type=argparse.FileType('wb'))
    params = ap.parse_args()

    # Build dictionary
    d = {}
    with params.infile as fin:        
        for line in fin:
            # parse each line
            cols = line.strip('\n').split('\t')
            chrom = cols[1].replace('chr','')
            pos = cols[2]
            ref = cols[7]
            observed = cols[9].split('\t')
            if ref == observed[0]:
                alt = observed[1]
            else:
                alt = observed[0]
            rsid = cols[4]
            d[(chrom, pos, ref, alt)] = rsid
            

    # Pickle the dict
    with params.outfile as fo:
        cPickle.dump(d, fo, cPickle.HIGHEST_PROTOCOL)
    

if __name__ == '__main__':
    main()
