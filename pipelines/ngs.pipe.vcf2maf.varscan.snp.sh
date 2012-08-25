#!/bin/bash
## 
## DESCRIPTION:   Given an varscan output snp vcf file, convert it to maf format
##
## USAGE:         ngs.pipe.vcf2maf.varscan.snp.sh
##                                                sample_id
##                                                sample.varscan.snp.vcf
##                                                [snpeff_genome_version(default GRCh37.64)]
##
## OUTPUT:        sample.varscan.snp.somatic.snpeff.vcf.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
SAMPLE_ID=$1
SNP_VCF=$2
SNPEFF_GENOME_VERSION=$3
PREFIX_SNP=`filter_ext $SNP_VCF 1`

# Create temporary directory
TMPDIR=tmp.vcf2maf.varscan.snp.$RANDOM
mkdir $TMPDIR

# Annotate and create maf files ===========================================================#
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid

# Filter for somatic
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_SNP.vcf                                               \
          -o $PREFIX_SNP.somatic.vcf

# Annotate
$NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh $PREFIX_SNP.somatic.vcf $SNPEFF_GENOME_VERSION

# Convert to maf format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf.py                                       \
          $PREFIX_SNP.somatic.snpeff.vcf                                                   \
          $SAMPLE_ID                                                                       \
          $GENE2ENTREZ                                                                     \
          -e                                                                               \
          -t varscan                                                                       \
          -o $PREFIX_SNP.somatic.snpeff.vcf.maf
