#!/bin/bash
##
## DESCRIPTION:   Run FastQC on multiple fastqc files using grid engine
## 
## USAGE:         ngs.pipe.fastqc.ge.sh
##                                      num_threads_each
##                                      in1.fastq.gz
##                                      [in2.fastq.gz [...]]
##
## OUTPUT:        Fastqc outputs for each fastq.gz file inputted
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_THREAD=${PARAMS[0]}
NUM_FASTQS=$(($NUM_PARAMS - 1))
FASTQFILES=${PARAMS[@]:1:$NUM_FASTQS}

# Run tool
for fastqfile in $FASTQFILES; do
  qsub_wrapper.sh fastqc                                                                          \
                  all.q                                                                           \
                  $NUM_THREAD                                                                     \
                  4G                                                                              \
                  none                                                                            \
                  n                                                                               \
                  $NGS_ANALYSIS_DIR/modules/seq/fastqc.sh $fastqfile $NUM_THREAD
done
