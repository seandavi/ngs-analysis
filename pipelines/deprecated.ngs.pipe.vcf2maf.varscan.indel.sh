#!/bin/bash
## 
## DESCRIPTION:   Given a varscan output indel vcf file, convert it to maf format
##
## USAGE:         ngs.pipe.vcf2maf.varscan.indel.sh
##                                                  sample_id
##                                                  sample.varscan.indel.vcf
##                                                  [snpeff_genome_version(default GRCh37.64)]
##
## OUTPUT:        sample.varscan.indel.somatic.clean.snpeff.vcf.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
SAMPLE_ID=$1
INDEL_VCF=$2
SNPEFF_GENOME_VERSION=$3
PREFIX_INDEL=`filter_ext $INDEL_VCF 1`

# Create temporary directory
TMPDIR=tmp.vcf2maf.varscan.indel.$RANDOM
mkdir $TMPDIR

# Annotate and create maf files ===========================================================#
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid

# Filter for somatic
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_INDEL.vcf                                             \
          -t somatic
          -o $PREFIX_INDEL.somatic.vcf

# Clean up indel file
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_clean_indel.py    \
          $PREFIX_INDEL.somatic.vcf                                     \
          -o $PREFIX_INDEL.somatic.clean.vcf

# Annotate
$NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh $PREFIX_INDEL.somatic.clean.vcf $SNPEFF_GENOME_VERSION

# # Fix indel format column and convert indel and snp to maf format
# $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_snpeff_indel_insert_format_field.py  \
#           $PREFIX_INDEL.somatic.clean.snpeff.vcf                                           \
#           -o $PREFIX_INDEL.somatic.clean.snpeff.format.vcf

# Convert to maf format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf.py                                       \
          $PREFIX_INDEL.somatic.clean.snpeff.vcf                                           \
          $SAMPLE_ID                                                                       \
          $GENE2ENTREZ                                                                     \
          -e                                                                               \
          -t varscan                                                                       \
          -o $PREFIX_INDEL.somatic.clean.snpeff.vcf.maf
