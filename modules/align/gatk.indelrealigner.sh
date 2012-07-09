#!/bin/bash
##
## DESCRIPTION:   Local realignment for more accurate indel calling
##
## USAGE:         gatk.indelrealigner.sh sample.bam sample.realign.intervals
##
## OUTPUT:        sample.realign.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

BAMFILE=$1
TARGETINTERVAL=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTBAM=$OUTPUTPREFIX.realign.bam
OUTPUTLOG=$OUTPUTBAM.log


# Run tool
$JAVAJAR $GATK                                            \
  -T IndelRealigner                                       \
  -R $REF                                                 \
  -I $BAMFILE                                             \
  -targetIntervals $TARGETINTERVAL                        \
  -o $OUTPUTBAM                                           \
  -l INFO                                                 \
  -known $MILLS_DEVINE_INDEL_VCF                          \
  -known $INDEL_1000G_PHASE1_VCF                          \
  -LOD 5.0                                                \
  -model USE_READS                                        \
  -entropy 0.15                                           \
  -maxInMemory 150000                                     \
  -maxIsize 3000                                          \
  -maxPosMove 200                                         \
  -maxConsensuses 30                                      \
  -greedy 120                                             \
  -maxReads 20000                                         \
  -compress 5                                             \
  &> $OUTPUTLOG


# Does not support -nt option

#
# --disable_bam_indexing                                               Turn off on-the-fly creation of indices for output 
#                                                                      BAM files.
# --generate_md5                                                       Enable on-the-fly creation of md5s for output BAM 
#                                                                      files.
# -simplifyBAM,--simplifyBAM                                           If provided, output BAM files will be simplified 
#                                                                      to include just key reads for downstream variation 
#                                                                      discovery analyses (removing duplicates, PF-, 
#                                                                      non-primary reads), as well stripping all extended 
#                                                                      tags from the kept reads except the read group 
#                                                                      identifier
# -noTags,--noOriginalAlignmentTags                                    Don't output the original cigar or alignment start 
#                                                                      tags for each realigned read in the output bam
# -nWayOut,--nWayOut <nWayOut>                                         Generate one output file for each input (-I) bam 
#                                                                      file
