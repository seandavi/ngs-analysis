#!/usr/bin/env python
description = '''
Parse annovar_summarize.pl tool output csv files
For accurate results, filters should be used one at a time
'''

import argparse
import csv
import sys
from ngs import annovar

def subcommand_count(args):
    with args.annovar_csv as f:
        csvreader = annovar.AnnovarCsv(f)
        # Run the counts
        try:
            col2varcounts, col2genes = csvreader.count(args.column_name)
        except ValueError:
            sys.stderr.write('Error while counting.  Check column name.\nExiting\n\n')
            sys.exit(1)
        else:
            # Output the results to standard output
            colvals = sorted(col2varcounts.keys())
            total = 0
            for col in colvals:
                if args.count_type == 'variant':
                    sys.stdout.write('%s\t%i\n' % (col, col2varcounts[col]))
                    total += col2varcounts[col]
                else:
                    num_genes = len(col2genes[col])
                    sys.stdout.write('%s\t%i\n' % (col, num_genes))
                    total += num_genes
            sys.stdout.write('Total\t%i\n' % total)

def subcommand_filter(args):
    with args.annovar_csv as f:
        csvreader = annovar.AnnovarCsv(f)
        filter_factory = annovar.AnnovarCsvFilterFactory()
        
        # Add filters
        # Genes
        if args.genes_select:
            with args.genes_select as f_genes:
                genes = [line.strip() for line in f_genes]
            csvreader.add_filter(filter_factory.create_genes_selector(set(genes)))
        
        if args.genes_filter:
            with args.genes_filter as f_genes:
                genes = [line.strip() for line in f_genes]
            csvreader.add_filter(filter_factory.create_genes_filter(set(genes)))

        # dbSNP
        if args.dbSNP_select:
            csvreader.add_filter(filter_factory.create_dbSNP_selector())

        if args.dbSNP_filter:
            csvreader.add_filter(filter_factory.create_dbSNP_filter())

        # Polyphen
        if args.polyphen_pred_select:
            csvreader.add_filter(filter_factory.create_polyphen_pred_selector(args.polyphen_pred_select))

        if args.sift_pred_select:
            csvreader.add_filter(filter_factory.create_sift_pred_selector(args.sift_pred_select))

        # 1000Genomes maf
        if args.maf_1000G_select:
            csvreader.add_filter(filter_factory.create_1000Genomes_maf_selector(minval=args.maf_1000G_select[0],
                                                                                maxval=args.maf_1000G_select[1]))

        # Run filters
        csvwriter = csv.writer(sys.stdout, dialect='excel')
        csvwriter.writerow(csvreader.header)
        for row in csvreader.filtered_variants():
            csvwriter.writerow(row)

def main():
    parser = argparse.ArgumentParser(description=description)
    
    subparsers = parser.add_subparsers(title='subcommands',
                                       description='Available tools',
                                       dest='subcommand')
    # Subcommand: Filter variants
    parser_filter = subparsers.add_parser('filter',
                                          help='Select for or filter out variants')
    
    parser_filter.add_argument('annovar_csv',
                               help='Input annovar output csv file',
                               nargs='?',
                               type=argparse.FileType('r'),
                               default=sys.stdin)
    parser_filter.add_argument('--genes-select',
                               help='Single-column file of gene names to select variants that are annotated with these gene',
                               type=argparse.FileType('r'))
    parser_filter.add_argument('--genes-filter',
                               help='Single-column file of gene names to filter (remove) variants that are annotated with these genes',
                               type=argparse.FileType('r'))
    parser_filter.add_argument('--dbSNP-select',
                               help='Select dbSNP variants',
                               action='store_true',
                               default=False)
    parser_filter.add_argument('--dbSNP-filter',
                               help='Filter out (remove) dbSNP variants',
                               action='store_true',
                               default=False)
    parser_filter.add_argument('--polyphen-pred-select',
                               nargs='*',
                               help='Select polyphen predictions, i.e. D B',
                               default=[])
    parser_filter.add_argument('--sift-pred-select',
                               nargs='*',
                               help='Select SIFT predictions, i.e. D T',
                               default=[])
    parser_filter.add_argument('--maf-1000G-select',
                               nargs=2,
                               help='Select 1000 Genomes maf range (min, max)',
                               type=float)
    parser_filter.set_defaults(func=subcommand_filter)

    # Subcommand: Count variants
    parser_count = subparsers.add_parser('count',
                                         help='Count variants or genes with respect to the values of a given column')
    parser_count.add_argument('annovar_csv',
                              help='Input annovar output csv file',
                              nargs='?',
                              type=argparse.FileType('r'),
                              default=sys.stdin)
    parser_count.add_argument('-t','--count-type',
                              help='Count by genes or variants',
                              choices=['gene','variant'],
                              default='gene')
    parser_count.add_argument('-c','--column-name',
                              help='Name of column to base the counts on (default ExonicFunc)',
                              type=str,
                              default='ExonicFunc')
    parser_count.set_defaults(func=subcommand_count)
    
    # Parse the arguments and call the corresponding function
    args = parser.parse_args()
    args.func(args)
                        

if __name__ == '__main__':
    main()
