#!/usr/bin/env python
description = '''
Manipulate pairs of fastq files
'''

import argparse
import contextlib
import sys
from ngs import fastq

def subcommand_lengthfilter(args):
    out_pe1 = open(args.out_pe_r1, 'w')
    out_pe2 = open(args.out_pe_r2, 'w')
    out_se = open(args.out_se, 'w')
    with contextlib.nested(args.fastq_read1, args.fastq_read2, out_pe1, out_pe2, out_se):
        fastqpairs = fastq.FastqFilePairs(args.fastq_read1, args.fastq_read2)
        # Loop through the pair lines
        for status, rec1, rec2 in fastqpairs.generate_length_tests(args.minlength):
            # If both fail, skip
            if status == fastq.FastqFilePairs.STATUS['BOTH_FAIL']:
                continue
            # If read 1 passes only, output read 1 data to single end read output file
            elif status == fastq.FastqFilePairs.STATUS['R1_PASS']:
                out_se.write('%s\n' % '\n'.join(rec1))
            # If read 2 passes only, output read 2 data to single end read output file
            elif status == fastq.FastqFilePairs.STATUS['R2_PASS']:
                out_se.write('%s\n' % '\n'.join(rec2))
            # Both pass
            else:
                out_pe1.write('%s\n' % '\n'.join(rec1))
                out_pe2.write('%s\n' % '\n'.join(rec2))

def main():
    parser = argparse.ArgumentParser(description=description)
    
    subparsers = parser.add_subparsers(title='subcommands',
                                       description='Available tools',
                                       dest='subcommand')
    # Subcommand: Filter by length
    parser_filter = subparsers.add_parser('lengthfilter',
                                          help='Filter reads by length')
    
    parser_filter.add_argument('fastq_read1',
                               help='Read 1 fastq file of paired reads',
                               nargs='?',
                               type=argparse.FileType('r'),
                               default=sys.stdin)
    parser_filter.add_argument('fastq_read2',
                               help='Read 2 fastq file of paired reads',
                               nargs='?',
                               type=argparse.FileType('r'),
                               default=sys.stdin)
    parser_filter.add_argument('-l', '--minlength',
                               help='Minimum length of a read',
                               type=int,
                               default=1)
    parser_filter.add_argument('--out-pe-r1',
                               help='Name of output file for filtered read 1',
                               type=str,
                               default='filtered.R1.fastq')
    parser_filter.add_argument('--out-pe-r2',
                               help='Name of output file for filtered read 2',
                               type=str,
                               default='filtered.R2.fastq')
    parser_filter.add_argument('--out-se',
                               help='Name of output file for filtered single reads',
                               type=str,
                               default='filtered.SE.fastq')                               
    parser_filter.set_defaults(func=subcommand_lengthfilter)
    
    # Parse the arguments and call the corresponding function
    args = parser.parse_args()
    args.func(args)
                        

if __name__ == '__main__':
    main()
