#!/bin/bash
## 
## DESCRIPTION:   Given a SE fastq file, generate raw (unprocessed by GATK) bam
##
## USAGE:         ngs.pipe.fastq2rawbam.se.sh
##                                            Sample_AAAAAA_L00N_R1_NNN.fastq.gz
##                                            ref.fa
##
## OUTPUT:        Sample_AAAAAA_L00N_R1_NNN.fastq.gz.trim.fastq.sai.sort.rg.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input params
FASTQ_R1=$1
REFERENCE=$2

# Set up pipeline variables
SAMPLE=`$PYTHON $NGS_ANALYSIS_DIR/modules/util/illumina_fastq_extract_samplename.py $FASTQ_R1`

#==[ Trim ]=========================================================================#

$NGS_ANALYSIS_DIR/modules/seq/sickle.se.sh                   \
  $FASTQ_R1                                                  \

assert_normal_exit_status $? "Error during trimming. Exiting"

#==[ Align ]========================================================================#

# Align
$NGS_ANALYSIS_DIR/modules/align/bwa.aln.sh                   \
  $FASTQ_R1.trim.fastq                                       \
  $REFERENCE

assert_normal_exit_status $? "Error during bwa.aln.sh Exiting"

# Create sam
$NGS_ANALYSIS_DIR/modules/align/bwa.samse.sh                 \
  $FASTQ_R1.trim.fastq.sai                                   \
  $FASTQ_R1.trim.fastq.sai                                   \
  $FASTQ_R1.trim.fastq                                       \
  $REFERENCE

assert_normal_exit_status $? "Error during bwa.samse.sh. Exiting"

# Create bam
$NGS_ANALYSIS_DIR/modules/align/samtools.sam2sortedbam.sh    \
  $FASTQ_R1.trim.fastq.sai.sam.gz

assert_normal_exit_status $? "Error during sam2sortedbam. Exiting"

#==[ Merge, sort, and add read group ]==============================================#

# Add read group to bam file
$NGS_ANALYSIS_DIR/modules/align/picard.addreadgroup.sh       \
  $FASTQ_R1.trim.fastq.sai.sort.bam                          \
  $SAMPLE

assert_normal_exit_status $? "Error during picard.addreadgroup.sh. Exiting"