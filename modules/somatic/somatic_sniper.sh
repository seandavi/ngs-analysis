#!/bin/bash
##
## DESCRIPTION:   Run SomaticSniper on a tumor/normal pair of bam files
##
## USAGE:         somatic_sniper.sh normal.bam tumor.bam output_prefix
##
## OUTPUT:        output_prefix.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

BAM_NORM=$1
BAM_TUMOR=$2
OUT_PREFIX=$3

# Run tool
$SOMATIC_SNIPER                 \
  -J                            \
  -Q 15                         \
  -F vcf                        \
  -q 1                          \
  -f $REF                       \
  $BAM_TUMOR                    \
  $BAM_NORM                     \
  $OUT_PREFIX.vcf               \
  &> $OUT_PREFIX.vcf.log        
