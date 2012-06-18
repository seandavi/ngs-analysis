#!/usr/bin/env python
description = '''
Read in a data file, and read in a file containing labels that are sorted in decreasing priority from top to bottom
Attach the topmost priority found in the data to each record in the data file.

Read in a vcf file outputted by SNPEff, and read in the Effects categories file containing 2 columns (Impact,Effect)
Parse and output the data in the vcf file
'''

import argparse
import re
import sys

def load_effects_categories(effects_file):
    '''
    Read tab separated effects file, and generate a dictionary that maps effects to impact (col1 to col0)
    Also generate a list in decreasing priority order of the effects
    '''
    try:
        f = open(effects_file, 'r')
    except IOError:
        sys.stderr.write('Could not open effects file. Exiting.\n\n')
        sys.exit(1)
    effects2impact = {}
    effects = []
    for line in f:
        la = line.strip().split('\t')
        impact = la[0]
        effect = la[1]
        
        effects2impact[effect] = impact
        effects.append(effect)
    f.close()
    return effects, effects2impact


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

def parse_effect(info_str, effects):
    '''
    Parse the info column string in the vcf file, and extract the highest-priority effect, impact,
    and the corresponding gene name
    '''
    # Extract out the effects information string
    effect_info = re.search('EFF=(.*)', info_str).group(1)

    # Prioritize each effect information based on the effects list
    locus_effects = effect_info.split(',')
    locus_effects_priorities = []
    for le_string in locus_effects:
        locus_effect = re.search('(.+)\(', le_string).group(1)
        for i,e in enumerate(effects):
            if locus_effect == e:
                locus_effects_priorities.append(i)
                break

    # Extract out the effect, impact, and gene name
    highest_priority_num = min(locus_effects_priorities)
    for i,n in enumerate(locus_effects_priorities):
        if n == highest_priority_num:
            effect = re.search('(.+)\(', locus_effects[i]).group(1)
            effect_array = re.search('\((.+)\)', locus_effects[i]).group(1).split('|')
            effect_impact = effect_array[0]
            functional_class = effect_array[1]
            codon_change = effect_array[2]
            aa_change = effect_array[3]
            gene_name = effect_array[4]
            gene_biotype = effect_array[5]
            coding = effect_array[6]
            transcript = effect_array[7]
            exon = effect_array[8]
            return (effect, 
                    effect_impact,
                    functional_class,
                    codon_change,
                    aa_change,
                    gene_name,
                    gene_biotype,
                    coding,
                    transcript,
                    exon)

def append_to_sample_names(sampleslist, append_str):
    '''
    Input a list of sample names, and postfix them with additional string
    '''
    return ['_'.join([sample, append_str]) for sample in sampleslist]

def parse_file(fin, effects, effects2impact):
    '''
    Read through the vcf file, and parse it.
    Output the columns as defined above
    '''

    for line in fin:
        # Headers
        if line[0:2] == '##':
            continue

        # Column Labels: build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())
            sys.stdout.write('%s\n' % '\t'.join(['CHROM',
                                                 'POS',
                                                 'VARIANT_ID',
                                                 'REF',
                                                 'ALT',
                                                 'QUAL',
                                                 'FILTER',
                                                 'ALT_FREQ',
                                                 'TOTAL_DP',
                                                 'RMS_MQ',
                                                 'EFFECT',
                                                 'EFFECT_IMPACT',
                                                 'FUNCTIONAL_CLASS',
                                                 'CODON_CHANGE',
                                                 'AA_CHANGE',
                                                 'GENE_NAME',
                                                 'GENE_BIOTYPE',
                                                 'CODING',
                                                 'TRANSCRIPT',
                                                 'EXON',
                                                 './.',
                                                 '0/0',
                                                 '0/1',
                                                 '1/1',
                                                 'REF_HOMO_SAMPLE_IDS',
                                                 'VARIANT_HETERO_SAMPLE_IDS',
                                                 'VARIANT_HOMO_SAMPLE_IDS']
                                                + append_to_sample_names(sample_names, 'GT_allele')
                                                + append_to_sample_names(sample_names, 'GT_base')
                                                + append_to_sample_names(sample_names, 'DP')
                                                + append_to_sample_names(sample_names, 'GQ')
                                                + append_to_sample_names(sample_names, 'AD')))
    
            continue
        
        # Parse each row of data
        la = line.strip().split('\t')
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
        alt_freq = info_field2val['AF']
        total_dp = info_field2val['DP']
        rms_mq = info_field2val['MQ']
        (effect, 
         effect_impact,
         functional_class,
         codon_change,
         aa_change,
         gene_name,
         gene_biotype,
         coding,
         transcript,
         exon) = parse_effect(la[colname2colnum['INFO']], effects)
        
        # Keep track of genotypes for different calls
        nocall = []
        ref_homo = []
        variant_homo = []
        variant_hetero = []

        # Record sample alleles, genotypes, depth for alleles, genotype quality
        sample_gt_alleles = []
        sample_gt_bases = []
        sample_depths = []
        sample_gqs = []
        sample_allele_depths = []

        # Build sample info string format mapping
        sample_field2indx = build_sampleinfo_field2indx(la[colname2colnum['FORMAT']])
        for sample_name in sample_names:
            sample_i = colname2colnum[sample_name]
            sample_info_str = la[sample_i]

            # Check if 'no call'
            if sample_info_str == './.':
                sample_info_str = './.::::'

            sample_info_list = sample_info_str.split(':')
            sample_gt = sample_info_list[sample_field2indx['GT']]

            # Update output lists
            sample_gt_alleles.append(sample_gt)
            sample_gt_bases.append(convert_allele2bases(sample_gt, ref, alt))
            sample_depths.append(sample_info_list[sample_field2indx['DP']])
            sample_gqs.append(sample_info_list[sample_field2indx['GQ']])
            sample_allele_depths.append(sample_info_list[sample_field2indx['AD']])

            # Update genotype counts and sample names
            # Check if 'no call'
            if sample_gt == './.':
                nocall.append(sample_name)

            # Check reference homo
            elif sample_gt == '0/0':
                ref_homo.append(sample_name)

            # Check variant genotypes
            else:
                sample_alleles = sample_gt.split('/')
                if '1' in sample_alleles:
                    # Homo
                    if sample_alleles[0] == '1' and sample_alleles[1] == '1':
                        variant_homo.append(sample_name)
                    elif sample_alleles[0] == '1' or sample_alleles[1] == '1':
                        variant_hetero.append(sample_name)
                    else:
                        sys.stderr.write('Genotype format for sample %s is unknown: %s\n' % (sample_name, sample_info_str))
                        sys.exit(1)

        # Output to standard output
        sys.stdout.write('%s\n' % '\t'.join([chrom,
                                             pos,
                                             variantid,
                                             ref,
                                             alt,
                                             qual,
                                             filtr,
                                             alt_freq,
                                             total_dp,
                                             rms_mq,
                                             effect,
                                             effect_impact,
                                             functional_class,
                                             codon_change,
                                             aa_change,
                                             gene_name,
                                             gene_biotype,
                                             coding,
                                             transcript,
                                             exon,
                                             str(len(nocall)),
                                             str(len(ref_homo)),
                                             str(len(variant_hetero)),
                                             str(len(variant_homo)),
                                             ';'.join(ref_homo),
                                             ';'.join(variant_hetero),
                                             ';'.join(variant_homo)]
                                            + sample_gt_alleles
                                            + sample_gt_bases
                                            + sample_depths
                                            + sample_gqs
                                            + sample_allele_depths))

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('effects_categories_file',
                    help='File containing impacts and effects (2 columns) as defined by SNPEff')
    params = ap.parse_args()
    
    effects, effects2impact = load_effects_categories(params.effects_categories_file)
    parse_file(params.vcf_file, effects, effects2impact)
    params.vcf_file.close()


if __name__ == '__main__':
    main()
