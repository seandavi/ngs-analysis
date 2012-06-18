#!/usr/bin/env python

description = '''
Separate out a vcf file containing variant calls for multiple samples into individual samples
'''

import argparse
import sys

def build_colname2colnum(colname_str):
    '''
    Generate a dictionary that maps column name to the column index number
    Also generates a list of all the sample ids separately, which is a subset of the column names
    Also generates a sorted list of all the sample ids' indexes
    Assumes that sample ids are located to the right of the FORMAT column
    '''
    colnames = colname_str.split()
    colname2colnum = {}
    for i,colname in enumerate(colnames):
        colname2colnum[colname] = i

    # Sample ids
    first_sample_index = colname2colnum['FORMAT'] + 1
    sample_names = colnames[first_sample_index:]
    sample_indexes = sorted([colname2colnum[sn] for sn in sample_names])
    return colname2colnum, sample_names, sample_indexes

def separate_samples(vcfin, out_prefix, preserve_all=False):
    '''
    Read vcf file, and separate all samples into separate vcf files
    '''
    fouts = {}
    headerslist = []
    # Read through file
    for line in vcfin:
        
        # Headers: store into list of headers, to be outputted later
        if line[0:2] == '##':
            headerslist.append(line)
            continue
        
        # Column Labels: print and build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())

            # Start list of column descriptors until the "FORMAT" column
            new_coldesc = []
            for colname in line.strip().split('\t'):
                new_coldesc.append(colname)
                if colname == 'FORMAT':
                    break
            
            # Iterate through each sample name
            for sample in sample_names:

                # Create a file output handle for each sample
                fouts[sample] = open('.'.join([out_prefix, sample, 'vcf']), 'w')
                
                # Output vcf headers
                fouts[sample].write(''.join(headerslist))

                # Output column descriptors
                fouts[sample].write('%s\n' % ('\t'.join(new_coldesc + sample)))
                
            continue


        # Data
        la = line.strip().split('\t')

        # Parse line
        allele_ref = la[colname2colnum['REF']]
        allele_alt = la[colname2colnum['ALT']]
        genotype_field2indx = build_genotype_field2indx(la[colname2colnum['FORMAT']])

        # Start list of columns
        row_output_list = la[:colname2colnum['FORMAT'] + 1]
        
        # Iterate through list of samples
        for samplename in sample_names:
            sample_idx = colname2colnum[samplename]
            sample_genotype_info_str = la[sample_idx]
            sample_genotype_info = sample_genotype_info_str.split(':')

            # If all positions should be outputted, then just loop through and output everything
            if preserve_all:
                fouts[samplename].write('%s\n' % (row_output_list + sample_genotype_info_str))
                continue

            # If 'no call', and don't output anything
            if sample_genotype_info_str == './.' or sample_genotype_info[genotype_field2indx['GT']] == './.':
                continue

            # Check if variant, and output variants only to file
            sample_genotype = sample_genotype_info[genotype_field2indx['GT']]
            if sample_genotype != '0/0':
                fouts[samplename].write('%s\n' % (row_output_list + sample_genotype_info_str))

    # Close all file handles for each sample
    for fh in fouts.values():
        fh.close()


def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-a', '--preserve-all-positions',
                    help='Output genotypes for all positions, even if the sample is not variant at that position',
                    action='store_true')
    ap.add_argument('-o', '--out-prefix',
                    help='Output prefix',
                    type=str)
    params = ap.parse_args()
    
    if params.out_prefix:
        out_prefix = params.out_prefix
    else:
        if params.vcf_file != sys.stdin:
            out_prefix = '.'.join(params.vcf_file.name.split('.')[:-1])
        else:
            out_prefix = 'vcf_file'

    # Separate vcf file's samples and create a vcf file for each sample
    separate_samples(params.vcf_file, out_prefix, preserve_all=params.preserve_all_positions)
    params.vcf_file.close()


if __name__ == '__main__':
    main()
