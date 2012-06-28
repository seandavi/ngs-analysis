#!/bin/bash
##
## DESCRIPTION:   Sort and index bam file
##
## USAGE:         picard.sortsam.sh sample.bam
##
## OUTPUT:        sample.sorted.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

BAMFILE=$1

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.sorted.bam
OUTPUTERROR=$OUTPUTPREFIX.sorted.err

# Run tool
$JAVAJAR $PICARD_PATH/SortSam.jar                     \
  INPUT=$BAMFILE                                      \
  OUTPUT=$OUTPUTFILE                                  \
  SORT_ORDER=coordinate                               \
  MAX_RECORDS_IN_RAM=$PICARD_MAX_RECORDS_IN_RAM       \
  CREATE_INDEX=true                                   \
  VALIDATION_STRINGENCY=LENIENT                       \
  &> $OUTPUTERROR
