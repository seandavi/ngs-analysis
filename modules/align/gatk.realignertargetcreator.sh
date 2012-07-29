#!/bin/bash
##
## DESCRIPTION:   Create target intervals for realignment
##
## USAGE:         gatk.realignertargetcreator.sh sample.bam [num_threads [target_region.intervals]]
##
## OUTPUT:        sample.realign.intervals
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
NUM_THREADS=$2
TARGETREGION=$3
NUM_THREADS=${NUM_THREADS:=2}

# Set target interval option
TARGET_OPTION=''
if [ ! -z $TARGETREGION ]; then
  TARGET_OPTION='-L '$TARGETREGION
fi

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.realign.intervals
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
$JAVAJAR16G $GATK                                         \
  -T RealignerTargetCreator                               \
  -R $REF                                                 \
  -nt $NUM_THREADS                                        \
  -I $BAMFILE                                             \
  -o $OUTPUTFILE                                          \
  -l INFO                                                 \
  -known $MILLS_DEVINE_INDEL_SITES_VCF                    \
  -known $INDEL_1000G_PHASE1_VCF                          \
  -maxInterval 500                                        \
  -minReads 4                                             \
  -mismatch 0.0                                           \
  -window 10                                              \
  $TARGET_OPION                                           \
  &> $OUTPUTLOG
