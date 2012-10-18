#!/bin/bash
##
## DESCRIPTION:   Summarize gc statistics such as distribution and base quality in an alignment file
##
## USAGE:         picard.collectgcbiasmetrics.sh
##                                               sample.bam
##                                               ref.fa
##                                               [max_records_in_ram]
##
## OUTPUT:        sample.bam.gcbias.metrics
##                sample.bam.gcbias.pdf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
REFEREN=$2
MAXRECS=$3
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.gcbias
OMETRIC=$OPREFIX.metrics
O_CHART=$OPREFIX.pdf
OUT_LOG=$OPREFIX.log

# Run tool
`javajar 8g` $PICARD_PATH/CollectGcBiasMetrics.jar         \
  REFERENCE_SEQUENCE=$REFEREN                              \
  INPUT=$BAMFILE                                           \
  OUTPUT=$OMETRIC                                          \
  CHART=$O_CHART                                           \
  MAX_RECORDS_IN_RAM=$MAXRECS                              \
  VALIDATION_STRINGENCY=LENIENT                            \
  &> $OUT_LOG
