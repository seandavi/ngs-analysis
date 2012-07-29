#!/bin/bash
##
## DESCRIPTION:   Ensure that all mate-pair information is in sync between each read and its mate pair
##
## USAGE:         picard.fixmate.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.fixmate.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
MAX_RECORDS_IN_RAM=$2
MAX_RECORDS_IN_RAM=${MAX_RECORDS_IN_RAM:=1000000}

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.fixmate.bam
OUTPUTERROR=$OUTPUTPREFIX.fixmate.err

# Run tool
$JAVAJAR16G $PICARD_PATH/FixMateInformation.jar       \
  INPUT=$BAMFILE                                      \
  OUTPUT=$OUTPUTFILE                                  \
  SORT_ORDER=coordinate                               \
  MAX_RECORDS_IN_RAM=$MAX_RECORDS_IN_RAM              \
  VALIDATION_STRINGENCY=LENIENT                       \
  &> $OUTPUTERROR
