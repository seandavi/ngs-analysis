#!/usr/bin/env python
description = '''
Read in a vcf file outputted by SNPEff. 
Enumerate each transcript's effects counts.
Output format:

transcript_id
effect
n (counts)
'''

import argparse
import re
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
            sys.stderr.write('Could not recognize allele %s\nExiting' % allele_str)
            sys.exit(1)
    return '/'.join(bases)

def update_counts(info_str, t2e2c):
    '''
    Parse the info column string in the vcf file, and update the counts for
    transcripts' effects
    '''
    # Extract out the effects information string
    effect_info = re.search('EFF=(.*)', info_str).group(1)

    # Prioritize each effect information based on the effects list
    locus_effects = effect_info.split(',')
    locus_effects_priorities = []
    for le_string in locus_effects:
        effect = re.search('(.+)\(', le_string).group(1)
        effect_array = re.search('\((.+)\)', le_string).group(1).split('|')
        effect_impact = effect_array[0]
        functional_class = effect_array[1]
        codon_change = effect_array[2]
        aa_change = effect_array[3]
        gene_name = effect_array[4]
        gene_biotype = effect_array[5]
        coding = effect_array[6]
        transcript = effect_array[7]
        exon = effect_array[8]
        
        # Check if transcript id not in t2e2c
        if transcript not in t2e2c:
            t2e2c[transcript] = {}

        # Check if effect is seen for the first time in t2e2c[transcript]
        if effect not in t2e2c[transcript]:
            t2e2c[transcript][effect] = 0

        # Update counts for transcript's effect
        t2e2c[transcript][effect] += 1

def append_to_sample_names(sampleslist, append_str):
    '''
    Input a list of sample names, and postfix them with additional string
    '''
    return ['_'.join([sample, append_str]) for sample in sampleslist]

def count_transcript_effects(fin, transcript2effect2count)
    '''
    Read through the vcf file, and count the effects for each transcript
    Output the columns as defined above
    '''

    for line in fin:
        # Headers
        if line[0:2] == '##':
            continue

        # Column Labels: build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())
            continue
        
        # Parse each row of data
        la = line.strip().split()

        # Build info column field2val mapping
        info_field2val = build_info_field2val(la[colname2colnum['INFO']])

        # Record columns
        chrom = la[colname2colnum['CHROM']]
        pos = la[colname2colnum['POS']]
        variantid = la[colname2colnum['ID']]
        ref = la[colname2colnum['REF']]
        alt = la[colname2colnum['ALT']]
        qual = la[colname2colnum['QUAL']]
        filtr = la[colname2colnum['FILTER']]
        total_dp = info_field2val['DP']

        # Update transcripts' effects counts
        update_counts(la[colname2colnum['INFO']], transcript2effect2count)

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_files',
                    help='SNPEff annotated vcf files',
                    nargs='*',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()
    
    transcript2effect2count = {}
    for f in params.vcf_files:
        count_transcript_effects(f, transcript2effect2count)
        f.close()

    # Output results to standard output
    for tr in sorted(transcript2effect2count.keys()):
        for ef in sorted(transcript2effect2count[tr].keys()):
            sys.stdout.write('%s\t%s\t%i\n' % (tr, ef, transcript2effect2count[tr][ef]))


if __name__ == '__main__':
    main()
