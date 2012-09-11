#!/bin/bash
##
## DESCRIPTION:   Generate metrics about reads and alignments per read and read pairs
##
## USAGE:         picard.collectalignmentsummarymetrics.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.bam.alignsummary.metrics
##                sample.bam.alignsummary.pdf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
MAXRECS=$2
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.alignsummary
OMETRIC=$OPREFIX.metrics
OUT_LOG=$OPREFIX.log

# Run tool
$JAVAJAR16G $PICARD_PATH/CollectAlignmentSummaryMetrics.jar \
  INPUT=$BAMFILE                                            \
  OUTPUT=$OMETRIC                                           \
  MAX_RECORDS_IN_RAM=$MAXRECS                               \
  VALIDATION_STRINGENCY=LENIENT                             \
  &> $OUT_LOG
