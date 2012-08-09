#!/usr/bin/env python
description = '''
Given 2 vcf files, concatenate the variant rows together.
This tool assumes that the headers of the 2 vcf files are the same, so it will use the
header from the first vcf file as the output vcf header.
'''

import argparse
import sys

def build_sampleinfo_field2indx(field_str):
    '''
    Generate a dictionary that maps the sample genotype field to their corresponding index
    '''
    fields = field_str.split(':')
    field2indx = {}
    for i,fieldname in enumerate(fields):
        field2indx[fieldname] = i
    return field2indx

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

def build_info_field2val(field_str):
    '''
    Generate a dictionary that maps the info column fields to their corresponding values
    '''
    field_str_array = field_str.split(';')
    field2val = {}
    for p in field_str_array:
        pa = p.split('=')
        if len(pa) == 2:
            field2val[pa[0]] = pa[1]
    return field2val

def convert_allele2bases(allele_str, ref, alt):
    '''
    Given an allele string i.e. 0/0, 0/1, 1/1, convert to genotype string i.e. A/A, C/G
    '''
    alleles = allele_str.split('/')
    bases = []
    for a in alleles:
        if a == '0':
            bases.append(ref)
        elif a == '1':
            bases.append(alt)
        elif a == '.':
            bases.append('N')
        else:
            sys.stderr.write('Could not recognize allele %s\nExiting\n\n' % allele_str)
            sys.exit(1)
    return '/'.join(bases)

def cat_vcf(vcf1_fin, vcf2_fin):
    '''
    Read in 2 vcf files and concatenate
    '''

    # Output all of vcf1
    for line in vcf1_fin:
        sys.stdout.write(line)

    # Output vcf2, skipping the headers
    for line in vcf2_fin:
        # Headers
        if line[0] == '#':
            continue
        sys.stdout.write(line)

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file1',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('vcf_file2',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()
    
    # Generate maf
    cat_vcf(params.vcf_file1, params.vcf_file2)
    params.vcf_file1.close()
    params.vcf_file2.close()


if __name__ == '__main__':
    main()
