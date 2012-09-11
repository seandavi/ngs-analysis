#!/bin/bash
##
## DESCRIPTION:   Calculate mean quality score of reads in a bam file and generate chart
##
## USAGE:         picard.qualityscoredistribution.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.bam.qscoredist.metrics
##                sample.bam.qscoredist.pdf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
MAXRECS=$2
MAXRECS=${MAXRECS:=1000000}

# Format output filenames
OPREFIX=$BAMFILE.qscoredist
OMETRIC=$OPREFIX.metrics
O_CHART=$OPREFIX.pdf
OUT_LOG=$OPREFIX.log

# Run tool
`javajar 16g` $PICARD_PATH/QualityScoreDistribution.jar    \
  INPUT=$BAMFILE                                           \
  OUTPUT=$OMETRIC                                          \
  CHART=$O_CHART                                           \
  MAX_RECORDS_IN_RAM=$MAXRECS                              \
  VALIDATION_STRINGENCY=LENIENT                            \
  &> $OUT_LOG
