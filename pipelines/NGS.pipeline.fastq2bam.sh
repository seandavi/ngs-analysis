#!/bin/bash
## 
## DESCRIPTION:   Trim, align, merge, recalibrate, realign, dedup
##
## USAGE:         NGS.pipeline.fastq2bam.sh sample.R1.fastq.gz sample.R2.fastq.gz
##
## OUTPUT:        sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_R1=$1
FASTQ_R2=$2
SAMPLE_PREFIX=`filter_ext $FASTQ_R1 3`

#==[ Trim ]=========================================================================#

$NGS_ANALYSIS_DIR/modules/seq/sickle.pe.sh $FASTQ_R1 $FASTQ_R2

#==[ Align ]========================================================================#

# Align
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $SAMPLE_PREFIX.R1.trimmed.fastq
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $SAMPLE_PREFIX.R2.trimmed.fastq
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $SAMPLE_PREFIX.SE.trimmed.fastq

# Create sam
$NGS_ANALYSIS_DIR/modules/align/bwa.sampe.sh             \
  $SAMPLE_PREFIX.R1.trimmed.sai                          \
  $SAMPLE_PREFIX.R2.trimmed.sai                          \
  $SAMPLE_PREFIX.R1.trimmed.fastq                        \
  $SAMPLE_PREFIX.R2.trimmed.fastq

$NGS_ANALYSIS_DIR/modules/align/bwa.samse.sh             \
  $SAMPLE_PREFIX.SE.trimmed.sai                          \
  $SAMPLE_PREFIX.SE.trimmed.fastq

# Create bam
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh $SAMPLE_PREFIX.PE.trimmed.sam.gz
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh $SAMPLE_PREFIX.SE.trimmed.sam.gz

#==[ Process bam file ]=============================================================#

# Merge paired and single end bam files
$NGS_ANALYSIS_DIR/modules/align/samtools.mergebam.sh    \
  $SAMPLE_PREFIX.PE.trimmed.sorted.bam                  \
  $SAMPLE_PREFIX.SE.trimmed.sorted.bam


# Sort
$NGS_ANALYSIS_DIR/modules/align/picard.sortsam.sh $SAMPLE_PREFIX.merged.bam

# Add read group to bam file
$NGS_ANALYSIS_DIR/modules/align/picard.addreadgroup.sh $SAMPLE_PREFIX.merged.sorted.bam $SAMPLE_PREFIX

# Qscore recalibration
# Count covariates
$NGS_ANALYSIS_DIR/modules/align/gatk.countcovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.bam
# Table recalibration
$NGS_ANALYSIS_DIR/modules/align/gatk.tablerecalibration.sh $SAMPLE_PREFIX.merged.sorted.rg.bam $SAMPLE_PREFIX.merged.sorted.rg.bam.recaldata.csv
# Count covariates again (after recal)
$NGS_ANALYSIS_DIR/modules/align/gatk.countcovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.bam
# Analyze Covariates before and after table recalibration
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.bam.recaldata.csv
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.bam.recaldata.csv

# Indel Realignment
