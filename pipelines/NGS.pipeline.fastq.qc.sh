#!/bin/bash
## 
## DESCRIPTION:   Generate QC for fastq pair
##
## USAGE:         NGS.pipeline.fastq.qc.sh sample.R1.fastq.gz sample.R2.fastq.gz
##
## OUTPUT:        Various fastq qc analysis results
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_R1=$1
FASTQ_R2=$2
SAMPLE_PREFIX=`filter_ext $FASTQ_R1 3`

#==[ Get fastq stats ]=========================================================================#

$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_stats.py $FASTQ_R1 &
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_stats.py $FASTQ_R2 &
wait

#==[ Get fastq quality score summmary ]========================================================#

$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_scores.py $FASTQ_R1 &
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_scores.py $FASTQ_R2 &
wait

#==[ Run FastQC ]==============================================================================#
$FASTQC $FASTQ_R1 &
$FASTQC $FASTQ_R2 &
wait