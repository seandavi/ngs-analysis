#!/bin/bash
## 
## DESCRIPTION:   Generate QC for fastq pair
##
## USAGE:         ngs.pipe.fastq.qc.sh 
##                                     Samplename_AAAAAA_L00N_R1_001.fastq.gz
##                                     Samplename_AAAAAA_L00N_R2_001.fastq.gz
##
## OUTPUT:        Various fastq qc analysis results
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_R1=$1
FASTQ_R2=$2
SAMPLE_PREFIX=`$PYTHON $NGS_ANALYSIS_DIR/modules/util/illumina_fastq_extract_samplename.py $FASTQ_R1`

#==[ Get fastq stats ]=========================================================================#

$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_stats.py $FASTQ_R1
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_stats.py $FASTQ_R2

#==[ Get fastq quality score summmary ]========================================================#

$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_scores.py $FASTQ_R1
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/fastq_scores.py $FASTQ_R2

#==[ Run FastQC ]==============================================================================#
$NGS_ANALYSIS_DIR/modules/seq/fastqc.sh $FASTQ_R1 1
$NGS_ANALYSIS_DIR/modules/seq/fastqc.sh $FASTQ_R2 1
