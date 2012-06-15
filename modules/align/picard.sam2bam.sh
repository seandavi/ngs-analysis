#!/bin/bash
##
## DESCRIPTION: Convert a BAM file to a SAM file, or BAM to SAM.
##
## USAGE: picard.sam2bam.sh sample.sam[.gz]
##
## OUTPUT: sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

SAMFILE=$1

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
$JAVAJAR $PICARD_PATH/SamFormatConverter.jar     \
  INPUT=$SAMFILE                                 \
  OUTPUT=$OUTPUTFILE                             \
  MAX_RECORDS_IN_RAM=$PICARD_MAX_RECORDS_IN_RAM  \
  VALIDATION_STRINGENCY=LENIENT                  \
  &> $OUTPUTERROR

