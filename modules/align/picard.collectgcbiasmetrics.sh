#!/bin/bash
##
## DESCRIPTION:   Summarize gc statistics such as distribution and base quality in an alignment file
##
## USAGE:         picard.collectgcbiasmetrics.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.bam.gcbias.metrics
##                sample.bam.gcbias.pdf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
MAXRECS=$2
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.gcbias
OMETRIC=$OPREFIX.metrics
O_CHART=$OPREFIX.pdf
OUT_LOG=$OPREFIX.log

# Run tool
`javajar 16g` $PICARD_PATH/CollectGcBiasMetrics.jar        \
  INPUT=$BAMFILE                                           \
  OUTPUT=$OMETRIC                                          \
  CHART=$O_CHART                                           \
  MAX_RECORDS_IN_RAM=$MAXRECS                              \
  VALIDATION_STRINGENCY=LENIENT                            \
  &> $OUT_LOG
