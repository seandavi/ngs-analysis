#!/bin/bash
##
## DESCRIPTION:   Run varscan somatic on normal/tumor pair of mpileups
##
## USAGE:         varscan.somaticfilter.sh varscan_somatic_output_file varscan_somatic_indel_file
##
## OUTPUT:        varscan_somatic_output_file.somaticfilter
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

MUTATIONS_FILE=$1
INDEL_FILE=$2
OUT_PREFIX=$MUTATIONS_FILE
OUT_FILE=$OUT_PREFIX.somaticfilter
OUT_LOG=$OUT_FILE.log

# Run tool
$JAVAJAR16G $VARSCAN                    \
  somaticFilter                         \
  $MUTATIONS_FILE                       \
  --min-coverage  10                    \
  --min-reads2    4                     \
  --min-strands2  1                     \
  --min-avg-qual  20                    \
  --min-var-freq  0.20                  \
  --p-value       5e-02                 \
  --indel-file    $INDEL_FILE           \
  --output-file   $OUT_FILE             \
  --output-vcf 1                        \
  &> $OUT_LOG
