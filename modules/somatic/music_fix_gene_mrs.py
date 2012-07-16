#!/usr/bin/env python
description = '''
Fix gene_mrs file in case where
Covered_Bases > Mutations
Just set both to zero
'''

import argparse
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('gene_mrs',
                    help='Input gene_mrs file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()

    colhead = True
    for line in params.gene_mrs:

        if colhead:
            sys.stdout.write(line)
            colhead = False
            continue

        la = line.strip().split('\t')
        covered_bases = int(la[2])
        mutations = int(la[3])
        if covered_bases < mutations:
            la[2] = '0'
            la[3] = '0'
        sys.stdout.write('%s\n' % '\t'.join(la))

    params.gene_mrs.close()


if __name__ == '__main__':
    main()
