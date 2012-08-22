#!/bin/bash
## 
## DESCRIPTION:   Given a pair of PE fastq files, generate raw (unprocessed by GATK) bam
##
## USAGE:         ngs.pipe.fastq2bam.pe.sh
##                                          Sample_AAAAAA_L00N_R1_NNN.fastq.gz
##                                          Sample_AAAAAA_L00N_R2_NNN.fastq.gz
##                                          ref.fa
##
## OUTPUT:        Sample_AAAAAA_L00N_R1_NNN.fastq.gz.trim.fastq.sai.sort.mergepe.sort.rg.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

# Process input params
FASTQ_R1=$1
FASTQ_R2=$2
REFERENCE=$3
#FASTQ_R1=`ls $SAMPLEDIR/*_*_L???_R1_???.fastq.gz` # Sample_AAAAAA_L00N_R1_001.fastq.gz
#FASTQ_R2=`ls $SAMPLEDIR/*_*_L???_R2_???.fastq.gz` # Sample_AAAAAA_L00N_R2_001.fastq.gz

# Set up pipeline variables
SAMPLE=`$PYTHON $NGS_ANALYSIS_DIR/modules/util/illumina_fastq_extract_samplename.py $FASTQ_R1`
FASTQ_PE=`echo $FASTQ_R1 | sed 's/R1/PE/'`
FASTQ_SE=`echo $FASTQ_R1 | sed 's/R1/SE/'`
FASTQ_ME=`echo $FASTQ_R1 | sed 's/R1/ME/'`

#==[ Fastq QC ]=====================================================================#

$NGS_ANALYSIS_DIR/pipelines/ngs.pipe.fastq.qc.sh             \
  $FASTQ_R1                                                  \
  $FASTQ_R2

#==[ Trim ]=========================================================================#

$NGS_ANALYSIS_DIR/modules/seq/sickle.pe.sh                   \
  $FASTQ_R1                                                  \
  $FASTQ_R2

#==[ Align ]========================================================================#

# Align
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh                   \
  $FASTQ_R1.trim.fastq                                       \
  $REFERENCE
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh                   \
  $FASTQ_R2.trim.fastq                                       \
  $REFERENCE
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh                   \
  $FASTQ_SE.trim.fastq                                       \
  $REFERENCE

# Create sam
$NGS_ANALYSIS_DIR/modules/align/bwa.sampe.sh                 \
  $FASTQ_PE.trim.fastq.sai                                   \
  $FASTQ_R1.trim.fastq.sai                                   \
  $FASTQ_R2.trim.fastq.sai                                   \
  $FASTQ_R1.trim.fastq                                       \
  $FASTQ_R2.trim.fastq                                       \
  $REFERENCE
$NGS_ANALYSIS_DIR/modules/align/bwa.samse.sh                 \
  $FASTQ_SE.trim.fastq.sai                                   \
  $FASTQ_SE.trim.fastq.sai                                   \
  $FASTQ_SE.trim.fastq                                       \
  $REFERENCE

# Create bam
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh    \
  $FASTQ_PE.trim.fastq.sai.sam.gz
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh    \
  $FASTQ_SE.trim.fastq.sai.sam.gz

#==[ Merge, sort, and add read group ]==============================================#

# Merge paired and single end bam files
$NGS_ANALYSIS_DIR/modules/align/samtools.mergebam.sh         \
  $FASTQ_ME.trim.fastq.sai.sort.mergepe                      \
  $FASTQ_PE.trim.fastq.sai.sort.bam                          \
  $FASTQ_SE.trim.fastq.sai.sort.bam

# Sort
$NGS_ANALYSIS_DIR/modules/align/picard.sortsam.sh            \
  $FASTQ_ME.trim.fastq.sai.sort.mergepe.bam

# Add read group to bam file
$NGS_ANALYSIS_DIR/modules/align/picard.addreadgroup.sh       \
  $FASTQ_ME.trim.fastq.sai.sort.mergepe.sort.bam             \
  $SAMPLE
