#!/bin/bash
## 
## DESCRIPTION:   Given varscan output vcf files (snp and indel), convert them to maf format
##
## USAGE:         NGS.pipeline.varscan.vcf2maf.sh sample.varscan.snp.vcf sample.varscan.indel.vcf
##
## OUTPUT:        sample.varscan.snp.somatic.snpeff.vcf.maf sample.varscan.indel.somatic.clean.snpeff.format.vcf.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input parameters
SNP_VCF=$1
INDEL_VCF=$2
PREFIX_SNP=`filter_ext $SNP_VCF 1`
PREFIX_INDEL=`filter_ext $INDEL_VCF 1`

# Create temporary directory
TMPDIR=tmp.varscan.vcf2maf.$RANDOM
mkdir $TMPDIR

# Annotate and create maf files ===========================================================#
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid

# Filter for somatic
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_SNP.vcf                                               \
          -o $PREFIX_SNP.somatic.vcf

$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_INDEL.vcf                                             \
          -o $PREFIX_INDEL.somatic.vcf

# Clean up indel file
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_clean_indel.py    \
          $PREFIX_INDEL.somatic.vcf                                     \
          -o $PREFIX_INDEL.somatic.clean.vcf

# Annotate
$NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh $PREFIX_SNP.somatic.vcf
$NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh $PREFIX_INDEL.somatic.clean.vcf

# Fix indel format column and convert indel and snp to maf format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_snpeff_indel_insert_format_field.py  \
          $PREFIX_INDEL.somatic.clean.snpeff.vcf                                           \
          -o $PREFIX_INDEL.somatic.clean.snpeff.format.vcf

# Convert indel and snp to maf format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf_select_highest_transcript.py             \
          $PREFIX_SNP.somatic.snpeff.vcf                                                   \
          $SAMPL                                                                           \
          $GENE2ENTREZ                                                                     \
          -o $PREFIX_SNP.somatic.snpeff.vcf.maf
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf_select_highest_transcript.py             \
          $PREFIX_INDEL.somatic.clean.snpeff.format.vcf                                    \
          $SAMPL                                                                           \
          $GENE2ENTREZ                                                                     \
          -o $PREFIX_INDEL.somatic.clean.snpeff.format.vcf.maf
