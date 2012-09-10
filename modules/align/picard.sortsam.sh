#!/bin/bash
##
## DESCRIPTION:   Sort and index bam file
##
## USAGE:         picard.sortsam.sh sample.bam [max_records_in_ram]
##
## OUTPUT:        sample.sort.bam
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
OUTPUTFILE=$OUTPUTPREFIX.sort.bam
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
$JAVAJAR16G $PICARD_PATH/SortSam.jar                  \
  INPUT=$BAMFILE                                      \
  OUTPUT=$OUTPUTFILE                                  \
  SORT_ORDER=coordinate                               \
  MAX_RECORDS_IN_RAM=$MAX_RECORDS_IN_RAM              \
  CREATE_INDEX=true                                   \
  VALIDATION_STRINGENCY=LENIENT                       \
  &> $OUTPUTLOG
