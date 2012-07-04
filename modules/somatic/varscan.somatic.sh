#!/bin/bash
##
## DESCRIPTION:   Run varscan somatic on normal/tumor pair of mpileups
##
## USAGE:         varscan.somatic.sh normal.mpileup tumor.mpileup out_prefix somatic_pval tumor_purity 
##
## OUTPUT:        sample.fixmate.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

PILEUP_NORM=$1
PILEUP_TUMOR=$2
OUT_PREFIX=$3
SOMATIC_PVAL=$4
TUMOR_PURITY=$5

# Run tool
$VARSCAN                                \
  somatic                               \
  $PILEUP_NORM                          \
  $PILEUP_TUMOR                         \
  $OUT_PREFIX                           \
  --min-coverage-normal 10              \
  --min-coverage-tumor 6                \
  --min-var-freq 0.25                   \
  --min-freq-for-hom 0.80               \
  --normal-purity 1.00                  \
  --tumor-purity $TUMOR_PURITY          \
  --somatic-p-value $SOMATIC_PVAL       \
  --p-value 0.99                        \
  --strand-filter 1                     \
  &> $OUT_PREFIX.log

