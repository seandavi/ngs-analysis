#!/bin/bash
##
## DESCRIPTION:   Use grid engine to generate raw unprocessed bam files from SE fastq.gz files
## 
## USAGE:         ngs.pipe.fastq2rawbam.se.ge.sh
##                                               ref.fa
##                                               in1.fastq.gz
##                                               [in2.fastq.gz [...]]
##
## OUTPUT:        bam files for each inputted fastq.gz file
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
REFERENCEF=${PARAMS[0]}
NUM_FASTQS=$(($NUM_PARAMS - 1))
FASTQFILES=${PARAMS[@]:1:$NUM_FASTQS}

# Run tool
for fastqfile in $FASTQFILES; do
  qsub_wrapper.sh fastq2rawbam                                                                    \
                  all.q                                                                           \
                  2                                                                               \
                  none                                                                            \
                  n                                                                               \
                  $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.fastq2rawbam.se.sh $fastqfile $REFERENCEF
done
