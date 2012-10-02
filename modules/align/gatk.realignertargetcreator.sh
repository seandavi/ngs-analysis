#!/bin/bash
##
## DESCRIPTION:   Create target intervals for realignment
##
## USAGE:         gatk.realignertargetcreator.sh
##                                               sample.bam
##                                               ref.fasta
##                                               mills.indel.sites.vcf
##                                               1000G.indel.vcf
##                                               [num_threads [target_region.intervals]]
##
## OUTPUT:        sample.realign.intervals
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 4 $# $0

BAMFILE=$1
REF=$2
MILLS_INDEL=$3
INDEL_1000G=$4
NUM_THREADS=$5
TARGETREGION=$6
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
`javajar 8g` $GATK                                       \
  -T RealignerTargetCreator                               \
  -R $REF                                                 \
  -nt $NUM_THREADS                                        \
  -I $BAMFILE                                             \
  -o $OUTPUTFILE                                          \
  -l INFO                                                 \
  -known $MILLS_INDEL                                     \
  -known $INDEL_1000G                                     \
  -maxInterval 500                                        \
  -minReads 4                                             \
  -mismatch 0.0                                           \
  -window 10                                              \
  $TARGET_OPTION                                          \
  &> $OUTPUTLOG
