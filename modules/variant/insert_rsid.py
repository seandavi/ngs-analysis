#!/usr/bin/env python
description = '''
Read in tabular data containing variant information for each row
i.e. chromosome coordinates, ref and alt alleles
and insert a column of rsids to the specified column
'''

import argparse
import cPickle
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('infile',
                    help='Tabular data containing variant information for each row',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('mapfile',
                    help='Python pickled variant2rsid mapping file',
                    type=argparse.FileType('rb'))
    ap.add_argument('-k', '--variant-cols',
                    help='Chromosome col num, pos col num, ref col num, alt col num, all 0-based. i.e. 0 1 2 3',
                    nargs=4,
                    type=int,
                    default=[0,1,2,3])
    ap.add_argument('-i', '--insert-col',
                    help='Index of column to insert the rsids once it is found, 0-based',
                    type=int,
                    default=-1)
    ap.add_argument('-p', '--header-row',
                    help='Set flag to indicate that the infile has a header row',
                    action='store_true')
    params = ap.parse_args()

    # Load mapping file
    with params.mapfile as fin:
        var2rsid = cPickle.load(fin)

    # Pickle the dict
    with params.infile as fin:

        # Header row
        if params.header_row:
            line = fin.next()
            cols = line.strip('\n').split('\t')
            cols.insert(params.insert_col, 'RSID')
            sys.stdout.write('%s\n' % '\t'.join(cols))
            
        # Rest of data
        for line in fin:
            cols = line.strip('\n').split('\t')
            chrom = cols[params.variant_cols[0]].replace('chr','')
            coord = cols[params.variant_cols[1]]
            refal = cols[params.variant_cols[2]]
            altal = cols[params.variant_cols[3]]
            rsid = var2rsid.get((chrom, coord, refal, altal),'')

            # Insert into the row
            cols.insert(params.insert_col, rsid)

            # Output the results to standard output
            sys.stdout.write('%s\n' % '\t'.join(cols))
            

if __name__ == '__main__':
    main()
