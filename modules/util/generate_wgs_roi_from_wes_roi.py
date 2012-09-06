#!/usr/bin/env python
description = '''
Read in a roi (bed) file for wes, and generate a wgs version.
Basically, take the first exon start position, last exon end position,
and flank them with user-provided flank size.
'''

import argparse
import sys
from collections import defaultdict


DEFAULT_FLANK=2000

def update_pos(g2c2p, g, c, p, start=True):
    # First time seeing gene, or chromosome for gene
    if g not in g2c2p or c not in g2c2p[g]:
        g2c2p[g][c] = p
        return

    # Update start position
    if start:
        if p < g2c2p[g][c]:
            g2c2p[g][c] = p
    # Update end position
    else:
        if g2c2p[g][c] < p:
            g2c2p[g][c] = p

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('bedfile', 
                    help='Input bed format file',
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    ap.add_argument('-b', '--flanksize',
                    help='Flank size',
                    type=int,
                    default=DEFAULT_FLANK)
    params = ap.parse_args()

    # Maintain minimum start and maximum end positions
    g2c2s = defaultdict(dict)
    g2c2e = defaultdict(dict)
    # Read in bedfile and process data
    with params.bedfile as f:
        for line in f:
            la = line.strip().split()
            g = la[3]
            c = la[0]
            s = int(la[1])
            e = int(la[2])
            update_pos(g2c2s, g, c, s, start=True)
            update_pos(g2c2e, g, c, e, start=False)
    
    # Prepare for outputting results
    outputs = []
    for g in g2c2s:
        for c in g2c2s[g]:
            outputs.append((c, g2c2s[g][c], g2c2e[g][c], g))

    # Sort and output
    for row in sorted(outputs):
        c = row[0]
        s = str(max(row[1] - params.flanksize,0))
        e = str(row[2] + params.flanksize)
        g = row[3]
        sys.stdout.write('%s\t%s\t%s\t%s\n' % (c,s,e,g))
            

if __name__ == '__main__':
    main()
