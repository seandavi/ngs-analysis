#!/bin/bash
## 
## DESCRIPTION:   Trim, align, merge, recalibrate, realign, dedup
##
## USAGE:         NGS.pipeline.fastq2bam.sh 
##                                          Samplename_AAAAAA_L00N_R1_001.fastq.gz
##                                          Samplename_AAAAAA_L00N_R2_001.fastq.gz
##
## OUTPUT:        sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_R1=$1
FASTQ_R2=$2
FASTQ_SE=`echo $FASTQ_R1 | sed 's/R1/SE/'`
SAMPLE_PREFIX=`$PYTHON $NGS_ANALYSIS_DIR/modules/util/illumina_fastq_extract_samplename.py $FASTQ_R1`

#==[ Trim ]=========================================================================#

$NGS_ANALYSIS_DIR/modules/seq/sickle.pe.sh $FASTQ_R1 $FASTQ_R2

#==[ Align ]========================================================================#

# Align
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $FASTQ_R1.trimmed.fastq $SAMPLE_PREFIX.R1
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $FASTQ_R2.trimmed.fastq $SAMPLE_PREFIX.R2
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh $FASTQ_SE.trimmed.fastq $SAMPLE_PREFIX.SE

# Create sam
$NGS_ANALYSIS_DIR/modules/align/bwa.sampe.sh             \
  $SAMPLE_PREFIX.R1.sai                                  \
  $SAMPLE_PREFIX.R2.sai                                  \
  $FASTQ_R1.trimmed.fastq                                \
  $FASTQ_R2.trimmed.fastq

$NGS_ANALYSIS_DIR/modules/align/bwa.samse.sh             \
  $SAMPLE_PREFIX.SE.sai                                  \
  $FASTQ_SE.trimmed.fastq

# Create bam
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh $SAMPLE_PREFIX.PE.sam.gz
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh $SAMPLE_PREFIX.SE.sam.gz

#==[ Process bam file ]=============================================================#

# Merge paired and single end bam files
$NGS_ANALYSIS_DIR/modules/align/samtools.mergebam.sh     \
  $SAMPLE_PREFIX.merged                                  \
  $SAMPLE_PREFIX.PE.sorted.bam                           \
  $SAMPLE_PREFIX.SE.sorted.bam


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
# Analyze covariates before and after table recalibration
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.bam.recaldata.csv
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.bam.recaldata.csv

# Indel realignment
$NGS_ANALYSIS_DIR/modules/align/gatk.realignertargetcreator.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.bam $SURESELECT_INTERVAL
$NGS_ANALYSIS_DIR/modules/align/gatk.indelrealigner.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.bam $SAMPLE_PREFIX.merged.sorted.rg.recal.realign.intervals

# Remove duplicates
$NGS_ANALYSIS_DIR/modules/align/picard.markduplicates.sh $SAMPLE_PREFIX.merged.sorted.rg.recal.realign.bam

