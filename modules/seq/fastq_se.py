#!/usr/bin/env python
description = '''
Manipulate pairs of fastq files
'''

import argparse
import contextlib
import sys
from ngs import fastq

def subcommand_lengthfilter(args):
    with contextlib.nested(args.fastqfile, args.outfile) as (fin, fout):
        fastqfile = fastq.FastqFile(fin)
        # Loop through the records
        for rec in fastqfile.generate_length_filtered_records(args.minlength):
            fout.write('%s\n' % '\n'.join(rec))

def main():
    parser = argparse.ArgumentParser(description=description)
    
    subparsers = parser.add_subparsers(title='subcommands',
                                       description='Available tools',
                                       dest='subcommand')
    # Subcommand: Filter by length
    parser_filter = subparsers.add_parser('lengthfilter',
                                          help='Filter reads by length')
    
    parser_filter.add_argument('fastqfile',
                               help='Input fastq file',
                               nargs='?',
                               type=argparse.FileType('r'),
                               default=sys.stdin)
    parser_filter.add_argument('-l', '--minlength',
                               help='Minimum length of a read',
                               type=int,
                               default=1)
    parser_filter.add_argument('-o', '--outfile',
                               help='Name of output file for length filteed reads',
                               type=argparse.FileType('w'),
                               default=sys.stdout)                               
    parser_filter.set_defaults(func=subcommand_lengthfilter)
    
    # Parse the arguments and call the corresponding function
    args = parser.parse_args()
    args.func(args)
                        

if __name__ == '__main__':
    main()
