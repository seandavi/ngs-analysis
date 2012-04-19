#!/bin/bash
##
## DESCRIPTION: Sort and index bam file
##
## USAGE: picard.sortsam.sh sample.bam
##
## OUTPUT: sample.sorted.bam
##

# Load bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Check correct usage
usage 1 $# $0

# Format output filenames
OUTPUTPREFIX=`filter_ext $1 1`
OUTPUTFILE=$OUTPUTPREFIX.sorted.bam
OUTPUTERROR=$OUTPUTPREFIX.sorted.err

# Run tool
$JAVAJAR $PICARD_PATH/SortSam.jar                \
  INPUT=$1                                       \
  OUTPUT=$OUTPUTFILE                             \
  SORT_ORDER=coordinate                          \
  MAX_RECORDS_IN_RAM=$PICARD_MAX_RECORDS_IN_RAM  \
  CREATE_INDEX=true                              \
  VALIDATION_STRINGENCY=LENIENT                  \
  &> $OUTPUTERROR
