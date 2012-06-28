#!/bin/bash
##
## DESCRIPTION:   Create target intervals for realignment
##
## USAGE:         gatk.indelrealignertargetcreation.sh sample.bam [target_interval]
##
## OUTPUT:        sample.realign.intervals
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
TARGETINTERVAL=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.realign.intervals
OUTPUTLOG=$OUTPUTFILE.log

# If target interval is not set, then realign entire genome
if [ -z $TARGETINTERVAL ];
then
  # Run tool
  $JAVAJAR $GATK                                            \
    -T RealignerTargetCreator                               \
    -R $REF                                                 \
    -nt $GATK_NUM_THREADS                                   \
    -I $BAMFILE                                             \
    -o $OUTPUTFILE                                          \
    -l INFO                                                 \
    -known $DBSNP_VCF,$MILLS_DEVINE_INDEL_VCF               \
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
    -known $DBSNP_VCF,$MILLS_DEVINE_INDEL_VCF               \
    -maxInterval 500                                        \
    -minReads 4                                             \
    -mismatch 0.0                                           \
    -window 10                                              \
    -L $TARGETINTERVAL                                      \
    &> $OUTPUTLOG
fi
