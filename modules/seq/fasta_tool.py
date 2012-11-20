#!/usr/bin/env python
description = '''
Manipulate pairs of fastq files
'''

import argparse
import sys
from Bio import SeqIO

def subcommand_count(args):
    # Determine the type of comparison to make
    compare_fun = {'l': lambda seqlen: seqlen < args.length,
                   'g': lambda seqlen: seqlen > args.length,
                   'e': lambda seqlen: seqlen == args.length,
                   'le': lambda seqlen: seqlen <= args.length,
                   'ge': lambda seqlen: seqlen >= args.length}[args.type]

    with args.fastafile as fin:
        count = 0
        for rec in SeqIO.parse(fin, "fasta"):
            if compare_fun(len(rec.seq)):
                count += 1
    sys.stdout.write('%i\n' % count)


def main():
    parser = argparse.ArgumentParser(description=description)
    
    subparsers = parser.add_subparsers(title='subcommands',
                                       description='Available tools',
                                       dest='subcommand')
    # Subcommand: Count sequences
    parser_count = subparsers.add_parser('count',
                                          help='Count number of sequences')
    
    parser_count.add_argument('fastafile',
                               help='Input fasta file',
                               nargs='?',
                               type=argparse.FileType('r'),
                               default=sys.stdin)
    parser_count.add_argument('-l', '--length',
                               help='Length of sequence.  Default 1',
                               type=int,
                               default=1)
    parser_count.add_argument('-t', '--type',
                              help='Type of thresholding. I.e. ge will count sequences with length greater than or equal to the provided length value.  l=less_than, g=greater_than, e=equal_to, le=less_than_or_equal_to, ge=greather_than_or_equal_to. Default=ge',
                              type=str,
                              choices=['l','g','e','le','ge'],
                              default='ge')
    parser_count.set_defaults(func=subcommand_count)
    
    # Parse the arguments and call the corresponding function
    args = parser.parse_args()
    args.func(args)
                        

if __name__ == '__main__':
    main()
