#!/usr/bin/env python
description = '''
Convert Homo_sapiens.GRCh37.67.gtf downloaded from ensembl to bed file
Select only exome regions
'''

import argparse
import sys

def in_chroms(chrom):
    '''
    Check to see if chrom is in the desired set of chromosomes
    '''
    # Check regular chromosomes
    if chrom in [str(i) for i in range(1,23)] + ['X','Y','MT']:
        return True

    # Check super contigs
    if chrom[:2] == 'GL':
        return True

    return False

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('input_gtf',
                    help='Input gtf format file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()

    for line in params.input_gtf:
        la = line.strip().split('\t')
        
        seqname = la[0]
        source = la[1]
        feature = la[2]
        start = la[3]
        end = la[4]
        score = la[5]
        strand = la[6]
        frame = la[7]
        attributes = la[8]

        # If chromosome is not regular chromosome, skip
        if not in_chroms(seqname):
            continue

        # If not exon, skip
        if feature != 'exon':
            continue

        # Process chromosome name
        chrom = seqname.split('.')[0].upper()

        # Process chromosome coords
        start = str(int(start) - 1)

        # Output to standard output
        sys.stdout.write('%s\n' % '\t'.join([chrom,
                                             start,
                                             end,
                                             ':'.join([attributes,
                                                       source,
                                                       feature,
                                                       score,
                                                       strand,
                                                       frame])]))
    params.input_gtf.close()


if __name__ == '__main__':
    main()
