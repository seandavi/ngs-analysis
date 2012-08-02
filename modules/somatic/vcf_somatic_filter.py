#!/usr/bin/env python

description = '''
Read vcf file output from VarScan or SomaticSniper, and filter out somatic variants based on the tumor sample
0=wildtype,1=germline,2=somatic,3=LOH,4=unknown
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
    ap.add_argument('-p', '--program',
                    help='Name of somatic variant caller used to generate vcf. VarScan (default) | SomaticSniper',
                    choices=['varscan','ssniper'],
                    default='varscan')
    ap.add_argument('-t', '--type',
                    help='Filter type: wildtype | germline | LOH | somatic(default) | unknown',
                    choices=['somatic','wildtype','germline','LOH','unknown'],
                    default='somatic')
    ap.add_argument('--min-dp-tumor',
                    help='Select variants where the depth of tumor is >= this value.  [0]',
                    type=int,
                    default=0)
    ap.add_argument('--min-dp-normal',
                    help='Select variants where the depth of normal is >= this value.  [0]',
                    type=int,
                    default=0)
    ap.add_argument('-o', '--outfile',
                    help='Output results file',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()
    
    # 0=wildtype,1=germline,2=somatic,3=LOH,4=unknown
    wanted_status = '2'
    if params.type == 'wildtype':
        wanted_status = '0'
    elif params.type == 'germline':
        wanted_status = '1'
    elif params.type == 'LOH':
        wanted_status = '3'
    elif params.type == 'unknown':
        wanted_status = '4'

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

        # Filter by variant type
        # 0=wildtype,1=germline,2=somatic,3=LOH,4=unknown
        if params.program == 'ssniper':
            status = tumor_genotype_info[genotype_field2indx['SS']]
        else: # varscan
            status = info_field2val['SS']

        # Skip rows that do not have the wanted somatic status
        if status != wanted_status:
            continue
        
        # Filter by tumor dp
        tumor_dp = int(tumor_genotype_info[genotype_field2indx['DP']])
        if tumor_dp < params.min_dp_tumor:
            continue

        # Filter by normal dp
        normal_dp = int(normal_genotype_info[genotype_field2indx['DP']])
        if normal_dp < params.min_dp_normal:
            continue

        params.outfile.write(line)

    params.outfile.close()
    params.vcf_file.close()
    
    
if __name__ == '__main__':
    main()


                  
