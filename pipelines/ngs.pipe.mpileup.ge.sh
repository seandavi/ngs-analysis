#!/bin/bash
## 
## DESCRIPTION:   Run samtools mpileup for each bamfile in a list of bamfiles
##                Use grid engine using qsub
##                Bamlist is a single column list of the paths to the bamfiles
##
## USAGE:         ngs.pipe.mpileup.ge.sh bamlist ref.fasta [ job_name ["samtools mpileup options"]]
##
## OUTPUT:        mpileups for the bamfiles listed in bamlist
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
JOBNAME=$3
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_OPTIONS=$(($NUM_PARAMS - 3))
OPTIONS=${PARAMS[@]:3:$NUM_OPTIONS}

# Qsub wrapper script path
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh

# Run samtools mpileup
for bamfile in `cat $BAMLIST`; do
  $QSUB $JOBNAME                                                                        \
        all.q                                                                           \
        1                                                                               \
        none                                                                            \
        n                                                                               \
        $NGS_ANALYSIS_DIR/modules/align/samtools.mpileup.sh $bamfile $REFEREN $OPTIONS
done
