#!/bin/bash
##
## DESCRIPTION:   Summarize efficiency of hybrid capture experiments
##
## USAGE:         picard.calculatehsmetrics.sh
##                                             sample.bam
##                                             bait_intervals
##                                             target_intervals
##                                             [max_records_in_ram]
##
## OUTPUT:        sample.bam.hybselect.metrics
##                sample.bam.hybselect.target.metrics
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
BAITINT=$2
TGT_INT=$3
MAXRECS=$4
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.hybselect
OMETRIC=$OPREFIX.metrics
OPERTGT=$OPERFIX.target.metrics
OUT_LOG=$OPREFIX.log

# Run tool
`javajar 16g` $PICARD_PATH/CalculateHsMetrics.jar               \
  INPUT=$BAMFILE                                                \
  OUTPUT=$OMETRIC                                               \
  BAIT_INTERVALS=$BAITINT                                       \
  TARGET_INTERVALS=$TGT_INT                                     \
  PER_TARGET_COVERAGE=$OPERTGT                                  \
  MAX_RECORDS_IN_RAM=$MAXRECS                                   \
  VALIDATION_STRINGENCY=LENIENT                                 \
  &> $OUT_LOG
