#!/usr/bin/env python
description = '''
Read in a vcf file outputted by SNPEff
Parse and output the data in tcga maf format
By default, every effect and transcript annotated per variant will be outputted as a row in the maf file.
'''

'''
TCGA maf Variant Classification categories:

Frame_Shift_Del
Frame_Shift_Ins
In_Frame_Del
In_Frame_Ins
Missense_Mutation
Nonsense_Mutation
Silent
Splice_Site
Translation_Start_Site
Nonstop_Mutation
3\'UTR
3\'Flank
5\'UTR
5\'Flank
IGR 
Intron
RNA
Targeted_Region
Indel
De_novo_Start_InFrame
De_novo_Start_OutOfFrame
'''

import argparse
import re
import sys
from ngs import vcf

SOMATIC_CALLER = {'VARSCAN': 'varscan',
                  'GATK_SOMATIC_INDEL_DETECTOR': 'gatk_somatic_indel_detector'}

SNPEFF2TCGA = {'SPLICE_SITE_ACCEPTOR': 'Splice_Site',
               'SPLICE_SITE_DONOR': 'Splice_Site',
               'START_LOST': 'Missense_Mutation',
               'EXON_DELETED': 'Frame_Shift_Del',
               'FRAME_SHIFT_INS': 'Frame_Shift_Ins',
               'FRAME_SHIFT_DEL': 'Frame_Shift_Del',
               'STOP_GAINED': 'Nonsense_Mutation',
               'STOP_LOST': 'Nonstop_Mutation',
               'NON_SYNONYMOUS_CODING': 'Missense_Mutation',
               'CODON_CHANGE': 'Missense_Mutation',
               'CODON_INSERTION': 'In_Frame_Ins',
               'CODON_CHANGE_PLUS_CODON_INSERTION': 'In_Frame_Ins',
               'CODON_DELETION': 'In_Frame_Del',
               'CODON_CHANGE_PLUS_CODON_DELETION': 'In_Frame_Del',
               'UTR_5_DELETED': '5\'UTR',
               'UTR_3_DELETED': '3\'UTR',
               'SYNONYMOUS_START': 'Silent',
               'NON_SYNONYMOUS_START': 'Missense_Mutation',
               'START_GAINED': 'De_novo_Start_InFrame',
               'SYNONYMOUS_CODING': 'Silent',
               'SYNONYMOUS_STOP': 'Silent',
               'NON_SYNONYMOUS_STOP': 'Nonsense_Mutation',
               'UTR_5_PRIME': '5\'UTR',
               'UTR_3_PRIME': '3\'UTR',
               'REGULATION': '5\'Flank',
               'UPSTREAM': '5\'Flank',
               'DOWNSTREAM': '3\'Flank',
               'GENE': 'Targeted_Region',
               'TRANSCRIPT': 'RNA',
               'EXON': 'Targeted_Region',
               'INTRON_CONSERVED': 'Intron',
               'INTRON': 'Intron',
               'INTRAGENIC': 'Targeted_Region',
               'INTERGENIC': 'IGR',
               'INTERGENIC_CONSERVED': 'IGR',
               'NONE': '',
               'CHROMOSOME': '',
               'CUSTOM': '',
               'CDS': 'Targeted_Region'}


def load_gene2entrez(filename):
    '''
    Given a filename, generate a mapping dict from gene2entrez
    '''
    gene2entrez = {}
    g2e_fin = open(filename, 'r')
    for line in g2e_fin:
        la = line.strip('\n').split('\t')
        gene = la[0]
        entrezid = la[1]
        if gene and entrezid:
            gene2entrez[gene] = entrezid
    g2e_fin.close()
    return gene2entrez

def parse_vcf(vcf_in, sampleid, gene2entrez, fout, highest_priority=False,  normal_sample='NORMAL', tumor_sample='TUMOR', tool=SOMATIC_CALLER['VARSCAN']):
    '''
    Read through the vcf file, and parse it.
    Output the columns as defined by TCGA maf format
    '''
    # Output header line
    fout.write('%s\n' % '\t'.join(['Hugo_Symbol',
                                   'Entrez_Gene_Id',
                                   'Center',
                                   'NCBI_Build',
                                   'Chromosome',
                                   'Start_position',
                                   'End_position',
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
                                   'Sequencer',
                                   'transcript_name',
                                   'amino_acid_change']))

    with vcf.SnpEffVcfFile(vcf_in, 'r') as vcffile:

        # Skip to the variants section of the vcf file
        vcffile.jump2variants()

        # Read in the variant lines
        while True:
            try:
                # Get parsed variant data
                variant = vcffile.read_variant()
            # EOF is reached
            except StopIteration:
                break

            info_map, info_single = vcffile.parse_info(variant)
            if highest_priority:
                effects = [vcffile.select_highest_priority_effect(variant)]
                # Check if there were no effects
                if effects[0] is None:
                    continue
            else:
                effects = vcffile.parse_effects(variant)

             # Record columns
            chrom = variant['CHROM']
            pos = variant['POS']
            variantid = variant['ID']
            ref = variant['REF']
            alt = variant['ALT']
            if tool == SOMATIC_CALLER['VARSCAN']:
                somatic_status = vcffile.SOMATIC_STATUS_CODE2TEXT[info_map['SS']]
            else:
                somatic_status = 'Somatic'

            # Variant type
            variant_type = 'SNP'
            len_ref = len(ref)
            len_alt = len(alt)
            if len_ref > 1 or len_alt > 1:
                if len_ref > len_alt:
                    variant_type = 'DEL'
                elif len_ref < len_alt:
                    variant_type = 'INS'
                else: # len_ref == len_alt
                    if len_ref == 2:
                        variant_type = 'DNP'
                    elif len_ref == 3:
                        variant_type = 'TNP'
                    else:
                        variant_type = 'ONP'

            # Rsid
            if variantid[0:2] != 'rs':
                variantid = 'novel'

            # Sample genotypes
            normal_gt = vcffile.get_sample_gt(variant, normal_sample).split('/')
            tumor_gt = vcffile.get_sample_gt(variant, tumor_sample).split('/')

            # Iterate over the effects
            for effect in effects:

                # If gene or transcript name is not found, skip
                if not effect.gene or not effect.transcript:
                    continue

                # If aa change, add 'p.'
                aa_change = effect.aa_change
                if aa_change:
                    aa_change = 'p.' + aa_change

                # Set up entrez id
                entrez_id = ''
                if effect.gene in gene2entrez:
                    entrez_id = gene2entrez[effect.gene]

                # Frame shift - determine whether insertion or deletion
                effect_val = effect.effect
                if effect_val == 'FRAME_SHIFT':
                    if len(ref) < len(alt):
                        effect_val = 'FRAME_SHIFT_INS'
                    else:
                        effect_val = 'FRAME_SHIFT_DEL'

                # Output to standard output
                UNAVAILABLE=''
                fout.write('%s\n' % '\t'.join(['_'.join([effect.gene, effect.transcript]),
                                               entrez_id,
                                               'sequencing.center',
                                               '37',
                                               chrom,
                                               pos,
                                               str(int(pos) + len(ref) - 1),
                                               '+',
                                               SNPEFF2TCGA[effect_val],
                                               variant_type,
                                               ref,
                                               tumor_gt[0],
                                               tumor_gt[1],
                                               variantid,
                                               UNAVAILABLE,
                                               sampleid,
                                               sampleid,
                                               normal_gt[0],
                                               normal_gt[1],
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               somatic_status,
                                               UNAVAILABLE,
                                               'WES',
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               UNAVAILABLE,
                                               'Illumina HiSeq',
                                               effect.transcript,
                                               aa_change]))

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    type=str)
    ap.add_argument('sample_id',
                    help='Name of sample for whom the vcf file pertains to, to be outputted in the maf file',
                    type=str)
    ap.add_argument('gene2entrez',
                    help='File containing gene2entrezid mapping',
                    type=str)
    ap.add_argument('-e', '--highest-priority-effect',
                    help='If this flag is set, the highest-priority effect transcript will be selected from each variant annotation',
                    action='store_true')
    ap.add_argument('--normal',
                    help='Normal sample name in the vcf file normal column',
                    type=str,
                    default='NORMAL')
    ap.add_argument('--tumor',
                    help='Tumor sample name in the vcf file tumor column',
                    type=str,
                    default='TUMOR')
    ap.add_argument('-t', '--somatic-caller',
                    help='Indicate what tool was used to call the somatic variants',
                    choices=SOMATIC_CALLER.values(),
                    default=SOMATIC_CALLER['VARSCAN'])
    ap.add_argument('-o', '--outfile',
                    help='Output result file',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()

    # Load gene2entrez id mapping
    gene2entrez = load_gene2entrez(params.gene2entrez)

    # Generate maf
    parse_vcf(params.vcf_file,
              params.sample_id,
              gene2entrez,
              params.outfile,
              highest_priority=params.highest_priority_effect,
              normal_sample=params.normal,
              tumor_sample=params.tumor,
              tool=params.somatic_caller)


if __name__ == '__main__':
    main()
