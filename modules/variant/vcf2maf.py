#!/usr/bin/env python
description = '''
Read in a vcf file outputted by SNPEff
Attach the topmost priority found in the data to each record in the data file.
Parse and output the data in tcga maf format
'''

import argparse
import re
import sys


def get_effects_categories():
    effects_cats = [['High','SPLICE_SITE_ACCEPTOR'],
                    ['High','SPLICE_SITE_DONOR'],
                    ['High','START_LOST'],
                    ['High','EXON_DELETED'],
                    ['High','FRAME_SHIFT'],
                    ['High','STOP_GAINED'],
                    ['High','STOP_LOST'],
                    ['Moderate','NON_SYNONYMOUS_CODING'],
                    ['Moderate','CODON_CHANGE'],
                    ['Moderate','CODON_INSERTION'],
                    ['Moderate','CODON_CHANGE_PLUS_CODON_INSERTION'],
                    ['Moderate','CODON_DELETION'],
                    ['Moderate','CODON_CHANGE_PLUS_CODON_DELETION'],
                    ['Moderate','UTR_5_DELETED'],
                    ['Moderate','UTR_3_DELETED'],
                    ['Low','SYNONYMOUS_START'],
                    ['Low','NON_SYNONYMOUS_START'],
                    ['Low','START_GAINED'],
                    ['Low','SYNONYMOUS_CODING'],
                    ['Low','SYNONYMOUS_STOP'],
                    ['Low','NON_SYNONYMOUS_STOP'],
                    ['Modifier','UTR_5_PRIME'],
                    ['Modifier','UTR_3_PRIME'],
                    ['Modifier','REGULATION'],
                    ['Modifier','UPSTREAM'],
                    ['Modifier','DOWNSTREAM'],
                    ['Modifier','GENE'],
                    ['Modifier','TRANSCRIPT'],
                    ['Modifier','EXON'],
                    ['Modifier','INTRON_CONSERVED'],
                    ['Modifier','INTRON'],
                    ['Modifier','INTRAGENIC'],
                    ['Modifier','INTERGENIC'],
                    ['Modifier','INTERGENIC_CONSERVED'],
                    ['Modifier','NONE'],
                    ['Modifier','CHROMOSOME'],
                    ['Modifier','CUSTOM'],
                    ['Modifier','CDS']]
    effects2impact = {}
    effects = []
    for row in effects_cats:
        impact = row[0]
        effect = row[1]
        effects2impact[effect] = impact
        effects.append(effect)
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

def somatic_status_code2text(code):
    '''
    Map the numeric code to the actual somatic status text
    0=Reference,1=Germline,2=Somatic,3=LOH, or 5=Unknown
    '''
    return {'0': 'Reference', 
            '1': 'Germline',
            '2': 'Somatic',
            '3': 'LOH',
            '5': 'Unknown'}[code]

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
            num_cols = len(colname2colnum)
            sys.stdout.write('%s\n' % '\t'.join(['Hugo_Symbol',
                                                 'Entrez_Gene_Id',
                                                 'Center',
                                                 'NCBI_Build',
                                                 'Chromosome',
                                                 'Start_Position',
                                                 'End_Position',
                                                 'Strand',
                                                 'Variant_Classification',
                                                 'Variant_Type',
                                                 'Reference_Allele',
                                                 'Tumor_Seq_Allele1',
                                                 'Tumor_Seq_Allele2',
                                                 'dbSNP_RS',
                                                 'dbSNP_Val_Status',
                                                 'Tumor_Sample_Barcode',
                                                 'Matched_Norm_Sample_Barcode',
                                                 'Match_Norm_Seq_Allele1',
                                                 'Match_Norm_Seq_Allele2',
                                                 'Tumor_Validation_Allele1',
                                                 'Tumor_Validation_Allele2',
                                                 'Match_Norm_Validation_Allele1',
                                                 'Match_Norm_Validation_Allele2',
                                                 'Verification_Status',
                                                 'Validation_Status',
                                                 'Mutation_Status',
                                                 'Sequencing_Phase',
                                                 'Sequence_Source',
                                                 'Validation_Method',
                                                 'Score',
                                                 'BAM_File',
                                                 'Sequencer']))
            continue
        
        # Parse each row of data
        la = line.strip().split()
        len_la = len(la)
        if len_la < num_cols:
            continue
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
        somatic_status = somatic_status_code2text(info_field2val['SS'])
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
        format_string = la[colname2colnum['FORMAT']]
        sample_field2indx = build_sampleinfo_field2indx(format_string)
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
        
            if sample_name == 'NORMAL':
                normal_gt = convert_allele2bases(sample_gt, ref, alt).split('/')
            elif sample_name == 'TUMOR':
                tumor_gt = convert_allele2bases(sample_gt, ref, alt).split('/')

        # Output to standard output
        UNAVAILABLE='N/A'
        sys.stdout.write('%s\n' % '\t'.join([gene_name,
                                             UNAVAILABLE,
                                             'Sequencing_Center',
                                             'GRCh37',
                                             chrom.replace('chr',''),
                                             pos,
                                             pos,
                                             '+',
                                             effect,
                                             'SNP',
                                             ref,
                                             tumor_gt[0],
                                             tumor_gt[1],
                                             variantid,
                                             UNAVAILABLE,
                                             UNAVAILABLE,
                                             UNAVAILABLE,
                                             normal_gt[0],
                                             normal_gt[1],
                                             '',
                                             '',
                                             '',
                                             '',
                                             'Unknown',
                                             'Unknown',
                                             somatic_status,
                                             UNAVAILABLE,
                                             'WES',
                                             UNAVAILABLE,
                                             UNAVAILABLE,
                                             UNAVAILABLE,
                                             'Hiseq2000']))

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()
    
    effects, effects2impact = get_effects_categories()
    parse_file(params.vcf_file, effects, effects2impact)
    params.vcf_file.close()


if __name__ == '__main__':
    main()