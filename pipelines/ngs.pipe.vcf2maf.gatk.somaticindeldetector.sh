#!/bin/bash
## 
## DESCRIPTION:   Given a GATK SomaticIndelDetector output vcf file, convert it to maf format
##
## USAGE:         ngs.pipe.vcf2maf.gatk.somaticindeldetector.sh
##                                                              sample_id
##                                                              sample.vcf
##                                                              [snpeff_genome_version(default GRCh37.64)]
##
## OUTPUT:        sample.somatic.snpeff.vcf.maf
##
#$ -cwd
#$ -N vcf2maf.somaticindel
#$ -S /bin/bash
#$ -j y
#$ -o .
#$ -e .
#$ -pe orte 1
#$ -l h_vmem=5G
#$ -q all.q

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
TMPDIR=tmp.vcf2maf.somaticindeldetector.$RANDOM
mkdir $TMPDIR

# Annotate and create maf files ===========================================================#
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid

# Filter for somatic
$NGS_ANALYSIS_DIR/modules/somatic/vcf_gatk_somaticindel_filter.somatic.sh $PREFIX_INDEL.vcf

# Annotate
$NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh $PREFIX_INDEL.somatic.vcf $SNPEFF_GENOME_VERSION

# Convert to maf format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf.py                                       \
          $PREFIX_INDEL.somatic.snpeff.vcf                                                 \
          $SAMPLE_ID                                                                       \
          $GENE2ENTREZ                                                                     \
          -t gatk_somatic_indel_detector                                                   \
          -o $PREFIX_INDEL.somatic.snpeff.vcf.maf
