#!/bin/bash
##
## DESCRIPTION:   Assess sequence coverage in bam file(s)
##
## USAGE:         gatk.analyzecovariates.sh input1.bam [input2.bam [...]]
##
## OUTPUT:        Coverage summaries
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILES=($@)
echo ${BAMFILES[0]}



exit


# Format output filenames
OUTPUTPREFIX=`filter_ext $RECALFILE 1`
OUTPUTDIR=$OUTPUTPREFIX.analyzecovariates
OUTPUTLOG=$OUTPUTDIR.log
OUTPUTERR=$OUTPUTDIR.err

# Run tool
$JAVAJAR $GATK_ANALYZECOVARIATES                  \
  -recalFile $RECALFILE                           \
  -outputDir $OUTPUTDIR                           \
  -l INFO                                         \
  -numRG -1                                       \
  -ignoreQ 5                                      \
  -maxQ 50                                        \
  -maxHist 0                                      \
  -log $OUTPUTLOG                                 \
  &> $OUTPUTERR
