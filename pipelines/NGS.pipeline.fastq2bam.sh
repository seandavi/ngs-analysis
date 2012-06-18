#!/bin/bash
## 
## DESCRIPTION: Trim, align, merge, recalibrate, realign, dedup
##
## USAGE: NGS.pipeline.fastq2bam.sh sample.R1.fastq.gz sample.R2.fastq.gz
##
## OUTPUT: sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_R1=$1
FASTQ_R2=$2
SAMPLE_PREFIX=`filter_ext $FASTQ_R1 3`

#==[ Trim ]=========================================================================#

sickle.pe.sh $FASTQ_R1 $FASTQ_R2

#==[ Align ]========================================================================#

bwa.aln.sh $SAMPLE_PREFIX.R1.trimmed.fastq.gz
bwa.aln.sh $SAMPLE_PREFIX.R2.trimmed.fastq.gz
bwa.aln.sh $SAMPLE_PREFIX.RS.trimmed.fastq.gz

bwa.sampe.sh                              \
    $SAMPLE_PREFIX.R1.trimmed.aln.sai     \
    $SAMPLE_PREFIX.R2.trimmed.aln.sai     \
    $SAMPLE_PREFIX.R1.trimmed.fastq.gz    \
    $SAMPLE_PREFIX.R2.trimmed.fastq.gz

bwa.samse.sh                              \
    $SAMPLE_PREFIX.RS.trimmed.aln.sai     \
    $SAMPLE_PREFIX.RS.trimmed.fastq.gz



sample.RP.sam.gz
sample.RS.sam.gz
    