#!/usr/bin/env python
description = '''
Read in a vcf file outputted by SNPEff. 
Check to see if a variant (row) has been annotated with multiple genes
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
            sys.stderr.write('Could not recognize allele %s\nExiting\n\n' % allele_str)
            sys.exit(1)
    return '/'.join(bases)

def check_variant(info_str, transcript2gene):
    '''
    Parse the info column string in the vcf file, and check if multiple genes are included.
    Return the number of genes and the transcripts list
    '''
    # Extract out the effects information string
    effect_info = re.search('EFF=(.*)', info_str).group(1)

    # Prioritize each effect information based on the effects list
    locus_effects = effect_info.split(',')
    transcripts = set()
    genes = set()
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
        
        if transcript in transcript2gene:
            transcripts.add(transcript)
            genes.add(transcript2gene[transcript])
        else:
            if len(transcript.strip()) > 0:
                sys.stderr.write('%s\nTranscript %s has no mapping to a gene\n\n' % (info_str,transcript))

    return len(genes), transcripts

def append_to_sample_names(sampleslist, append_str):
    '''
    Input a list of sample names, and postfix them with additional string
    '''
    return ['_'.join([sample, append_str]) for sample in sampleslist]

def load_mapping_file(mapping_file_in):
    '''
    Read mapping file, and generate a mapping from transcription id to gene
    '''
    transcript2gene = {}
    for line in mapping_file_in:
        la = line.strip().split('\t')
        gene = la[0]
        transcript = la[2]
        transcript2gene[transcript] = gene
    return transcript2gene

def check_multiple_genes(fin, transcript2gene):
    '''
    Read through the vcf file and look for variants that are annotated
    with multiple genes
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

        # Check
        num_genes, transcripts = check_variant(la[colname2colnum['INFO']], transcript2gene)
        if num_genes > 1:
            sys.stdout.write(line)
            sys.stdout.write('\t%i genes\n' % num_genes)
            for tr in transcripts:
                sys.stdout.write('\t\t%s\t%s\n' % (tr, transcript2gene[tr]))
            sys.stdout.write('\n')

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='SNPEff annotated vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('mapping_file',
                    help='Ensemble gene,geneid,transcriptid mapping file parsed from Ensembl\'s Homo_sapiens.GRChxx.xx.gtf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()
    
    # Load mapping file to memory
    transcript2gene = load_mapping_file(params.mapping_file)

    # Check 
    check_multiple_genes(params.vcf_file, transcript2gene)


if __name__ == '__main__':
    main()
