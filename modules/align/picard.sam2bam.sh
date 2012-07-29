#!/bin/bash
##
## DESCRIPTION:   Convert a .sam.gz file to a .bam file
##
## USAGE:         picard.sam2bam.sh sample.sam[.gz] [max_records_in_ram]
##
## OUTPUT:        sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

SAMFILE=$1
MAX_RECORDS_IN_RAM=$2
MAX_RECORDS_IN_RAM=${MAX_RECORDS_IN_RAM:=1000000}

# Format output filenames
ext=${SAMFILE##*.}
if [ $ext == "gz" ] 
then
  OUTPUTPREFIX=`filter_ext $SAMFILE 2`
else
  OUTPUTPREFIX=`filter_ext $SAMFILE 1`
fi
OUTPUTFILE=$OUTPUTPREFIX.bam
OUTPUTERROR=$OUTPUTPREFIX.bam.err


# Run tool
$JAVAJAR8G $PICARD_PATH/SamFormatConverter.jar   \
  INPUT=$SAMFILE                                 \
  OUTPUT=$OUTPUTFILE                             \
  MAX_RECORDS_IN_RAM=$MAX_RECORDS_IN_RAM         \
  VALIDATION_STRINGENCY=LENIENT                  \
  &> $OUTPUTERROR

