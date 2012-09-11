#!/bin/bash
##
## DESCRIPTION:   Add read group to input bam file
##
## USAGE:         picard.addreadgroup.sh sample.bam readgroupid [max_records_in_ram]
##
## OUTPUT:        sample.rg.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

BAMFILE=$1
READGROUP=$2
MAX_RECORDS_IN_RAM=$3
MAX_RECORDS_IN_RAM=${MAX_RECORDS_IN_RAM:=1000000}

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.rg.bam
OUTPUTLOG=$OUTPUTPREFIX.rg.bam.log

# Run tool
`javajar 8g` $PICARD_PATH/AddOrReplaceReadGroups.jar  \
  INPUT=$BAMFILE                                      \
  OUTPUT=$OUTPUTFILE                                  \
  SORT_ORDER=coordinate                               \
  RGID=$READGROUP                                     \
  RGLB=$READGROUP                                     \
  RGPL=illumina                                       \
  RGPU=solexa                                         \
  RGSM=$READGROUP                                     \
  RGCN=null                                           \
  RGDS=null                                           \
  MAX_RECORDS_IN_RAM=$MAX_RECORDS_IN_RAM              \
  CREATE_INDEX=true                                   \
  VALIDATION_STRINGENCY=LENIENT                       \
  &> $OUTPUTLOG
