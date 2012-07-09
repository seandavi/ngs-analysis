#!/bin/bash
##
## DESCRIPTION:   Create target intervals for realignment
##
## USAGE:         gatk.realignertargetcreator.sh sample.bam [target_region.intervals]
##
## OUTPUT:        sample.realign.intervals
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
TARGETREGION=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.realign.intervals
OUTPUTLOG=$OUTPUTFILE.log

# If target interval is not set, then realign entire genome
if [ -z $TARGETREGION ];
then
  # Run tool
  $JAVAJAR $GATK                                            \
    -T RealignerTargetCreator                               \
    -R $REF                                                 \
    -nt $GATK_NUM_THREADS                                   \
    -I $BAMFILE                                             \
    -o $OUTPUTFILE                                          \
    -l INFO                                                 \
    -known $MILLS_DEVINE_INDEL_SITES_VCF                    \
    -known $INDEL_1000G_PHASE1_VCF                          \
    -maxInterval 500                                        \
    -minReads 4                                             \
    -mismatch 0.0                                           \
    -window 10                                              \
    &> $OUTPUTLOG
# If target interval is set, realign target region only
else
  # Run tool
  $JAVAJAR $GATK                                            \
    -T RealignerTargetCreator                               \
    -R $REF                                                 \
    -nt $GATK_NUM_THREADS                                   \
    -I $BAMFILE                                             \
    -o $OUTPUTFILE                                          \
    -l INFO                                                 \
    -known $MILLS_DEVINE_INDEL_SITES_VCF                    \
    -known $INDEL_1000G_PHASE1_VCF                          \
    -maxInterval 500                                        \
    -minReads 4                                             \
    -mismatch 0.0                                           \
    -window 10                                              \
    -L $TARGETREGION                                        \
    &> $OUTPUTLOG
fi
