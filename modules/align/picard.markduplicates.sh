#!/bin/bash
##
## DESCRIPTION:   Remove duplicate records in bam
##
## USAGE:         picard.markduplicates.sh sample.bam 
##
## OUTPUT:        sample.dedup.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

BAMFILE=$1

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTBAM=$OUTPUTPREFIX.dedup.bam
OUTPUTLOG=$OUTPUTBAM.log


# Run tool
$JAVAJAR16G $PICARD_PATH/MarkDuplicates.jar          \
  INPUT=$BAMFILE                                     \
  OUTPUT=$OUTPUTBAM                                  \
  METRICS_FILE=$OUTPUTBAM.metrics                    \
  ASSUME_SORTED=false                                \
  REMOVE_DUPLICATES=true                             \
  CREATE_INDEX=true                                  \
  MAX_RECORDS_IN_RAM=$PICARD_MAX_RECORDS_IN_RAM      \
  MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000            \
  SORTING_COLLECTION_SIZE_RATIO=0.25                 \
  OPTICAL_DUPLICATE_PIXEL_DISTANCE=100               \
  VALIDATION_STRINGENCY=LENIENT                      \
  &> $OUTPUTLOG


#  COMMENT=                                           \
#  READ_NAME_REGEX=                                   \
