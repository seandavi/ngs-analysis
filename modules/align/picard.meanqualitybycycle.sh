#!/bin/bash
##
## DESCRIPTION:   Histogram of quality scores in an alignment file
##
## USAGE:         picard.meanqualitybycycle.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.bam.meanqual.metrics
##                sample.bam.meanqual.pdf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
MAXRECS=$2
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.meanqual
OMETRIC=$OPREFIX.metrics
O_CHART=$OPREFIX.pdf
OUT_LOG=$OPREFIX.log

# Run tool
$JAVAJAR16G $PICARD_PATH/MeanQualityByCycle.jar            \
  INPUT=$BAMFILE                                           \
  OUTPUT=$OMETRIC                                          \
  CHART=$O_CHART                                           \
  MAX_RECORDS_IN_RAM=$MAXRECS                              \
  VALIDATION_STRINGENCY=LENIENT                            \
  &> $OUT_LOG
