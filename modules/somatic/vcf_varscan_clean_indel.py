#!/usr/bin/env python

description = '''
Read varscan vcf output, and remove + and - signs in front of the
indel alternate alleles
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

def build_genotype_field2indx(field_str):
    '''
    Generate a dictionary that maps the sample genotype field to their corresponding index
    '''
    fields = field_str.split(':')
    field2indx = {}
    for i,fieldname in enumerate(fields):
        field2indx[fieldname] = i
    return field2indx

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

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-o', '--outfile',
                    help='Name of output result file',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()
    
    for line in params.vcf_file:
         # Headers: print w/o filtering
        if line[0:2] == '##':
            params.outfile.write(line)
            continue

        # Column Labels: print and build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())
            params.outfile.write(line)
            continue

        la = line.strip().split('\t')
        genotype_field2indx = build_genotype_field2indx(la[colname2colnum['FORMAT']])
        tumor_genotype_info_str = la[colname2colnum['TUMOR']]
        tumor_genotype_info = tumor_genotype_info_str.split(':')
        normal_genotype_info_str = la[colname2colnum['NORMAL']]
        normal_genotype_info = normal_genotype_info_str.split(':')

        # Parse INFO field
        info_field2val = build_info_field2val(la[colname2colnum['INFO']])

        ref = la[colname2colnum['REF']]
        alt = la[colname2colnum['ALT']]

        # INSERTIONS
        if alt[0] == '+':
            alt = ref + alt.replace('+', '')

        # DELETIONS
        elif alt[0] == '-':
            alt = alt.replace('-', '')
            tmp = ref
            ref = ref + alt
            alt = tmp

        else:
            sys.stderr.write('%s\nThis record is neither insertion or deletion!\nExiting.\n\n' % line)
            sys.exit(1)

        # Replace old with cleaned alleles
        la[colname2colnum['REF']] = ref
        la[colname2colnum['ALT']] = alt

        # Output to stdout
        params.outfile.write('%s\n' % '\t'.join(la))

    params.outfile.close()
    params.vcf_file.close()
    
    
if __name__ == '__main__':
    main()


                  
