#!/bin/bash
## 
## DESCRIPTION:   Generate statistics about fastq files
##
## USAGE:         ngs.pipe.fastq.stat.ge.sh
##                                          in1.fastq
##                                          [in2.fastq.gz
##                                          [in3.fastq.zip [...]]]
##
## OUTPUT:        Various fastq qc analysis results
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

FASTQS=$@

# Run tool
FASTQSTATS=$NGS_ANALYSIS_DIR/modules/seq/fastq_stats.py
for fastqfile in $FASTQS; do
  qsub_wrapper.sh fastqstats                                                                      \
                  all.q                                                                           \
                  1                                                                               \
                  none                                                                            \
                  n                                                                               \
                  $NGS_ANALYSIS_DIR/modules/util/python_ngs.sh $FASTQSTATS $fastqfile
done
