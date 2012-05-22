#!/bin/bash
##
## DESCRIPTION: Ensure that all mate-pair information is in sync between each read and its mate pair
##
## USAGE: picard.fixmate.sh sample.bam
##
## OUTPUT: sample.fixmate.bam
##

# Load bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Check correct usage
usage 1 $# $0

BAMFILE=$1

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.fixmate.bam
OUTPUTERROR=$OUTPUTPREFIX.fixmate.err

# Run tool
$JAVAJAR $PICARD_PATH/FixMateInformation.jar          \
  INPUT=$BAMFILE                                      \
  OUTPUT=$OUTPUTFILE                                  \
  SORT_ORDER=coordinate                               \
  MAX_RECORDS_IN_RAM=$PICARD_MAX_RECORDS_IN_RAM       \
  VALIDATION_STRINGENCY=LENIENT                       \
  &> $OUTPUTERROR
