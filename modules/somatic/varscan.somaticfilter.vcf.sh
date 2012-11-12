#!/bin/bash
##
## DESCRIPTION:   Run VarScan somaticFilter on varscan outputs
##
## USAGE:         varscan.somaticfilter.vcf.sh
##                                             sample.varscan.snp.vcf
##                                             sample.varscan.indel.vcf
##                                             somatic-p-value           (default 0.05)
##                                             min-coverage              (default 10)
##
## OUTPUT:        varscan_somatic_output_file.somaticfilter
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
SNPVCF=$1
INDVCF=$2
S_PVAL=$3
MINCOV=$4

# Check to make sure that input files exist
assert_file_exists_w_content $SNPVCF
assert_file_exists_w_content $INDVCF

# Set default param values
if [ -z "$S_PVAL" ]; then
  S_PVAL=0.05
fi
if [ -z "$MINCOV" ]; then
  MINCOV=10
fi

# Set up output filenames
OUT_PRE=`filter_ext $SNPVCF 1`
OUTFILE=$OUT_PRE.somaticfilter.vcf
OUT_LOG=$OUTFILE.log

# Run tool
`javajar 16g` $VARSCAN                  \
  somaticFilter                         \
  $SNPVCF                               \
  --min-coverage  $MINCOV               \
  --min-reads2    4                     \
  --min-strands2  1                     \
  --min-avg-qual  20                    \
  --min-var-freq  0.20                  \
  --p-value       $S_PVAL               \
  --indel-file    $INDVCF               \
  --output-file   $OUTFILE              \
  --output-vcf 1                        \
  &> $OUT_LOG
