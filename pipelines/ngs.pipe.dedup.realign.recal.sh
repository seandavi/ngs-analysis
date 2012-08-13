#!/bin/bash
## 
## DESCRIPTION:   Dedup, realign, and recalibrate a raw bam file
##
## USAGE:         ngs.pipe.dedup.realign.recal.sh
##                                                sample.bam
##                                                ref.fa
##                                                dbsnp.vcf
##                                                mills.indel.sites.vcf
##                                                1000G.indel.vcf
##                                                [target_interval]
##
## OUTPUT:        sample.dedup.realign.recal.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 5 $# $0

# Process input params
SAMPLEBAM=$1
REFERENCE=$2
DBSNP_VCF=$3
MILLS_INDEL_VCF=$4
INDEL_1000G_VCF=$5
TARGET_INTERVAL=$6

# Set up pipeline variables
SAMPLE_PREFIX=`filter_ext $SAMPLEBAM 1`

# Remove duplicates --------------------------------------------#
$NGS_ANALYSIS_DIR/modules/align/picard.markduplicates.sh       \
  $SAMPLE_PREFIX.bam

# Indel realignment --------------------------------------------#
$NGS_ANALYSIS_DIR/modules/align/gatk.realignertargetcreator.sh \
  $SAMPLE_PREFIX.dedup.bam                                     \
  $REFERENCE                                                   \
  $MILLS_INDEL_VCF                                             \
  $INDEL_1000G_VCF                                             \
  2                                                            \
  $TARGET_INTERVAL
$NGS_ANALYSIS_DIR/modules/align/gatk.indelrealigner.sh         \
  $SAMPLE_PREFIX.dedup.bam                                     \
  $SAMPLE_PREFIX.dedup.realign.intervals                       \
  $REFERENCE                                                   \
  $MILLS_INDEL_VCF                                             \
  $INDEL_1000G_VCF

# Qscore recalibration -----------------------------------------#
# Count covariates
$NGS_ANALYSIS_DIR/modules/align/gatk.countcovariates.sh        \
  $SAMPLE_PREFIX.dedup.realign.bam                             \
  $REFERENCE                                                   \
  $DBSNP_VCF
# Table recalibration
$NGS_ANALYSIS_DIR/modules/align/gatk.tablerecalibration.sh     \
  $SAMPLE_PREFIX.dedup.realign.bam                             \
  $SAMPLE_PREFIX.dedup.realign.recal.csv                       \
  $REFERENCE

# Count covariates again (after recal)
$NGS_ANALYSIS_DIR/modules/align/gatk.countcovariates.sh        \
  $SAMPLE_PREFIX.dedup.realign.recal.bam                       \
  $REFERENCE                                                   \
  $DBSNP_VCF

# Analyze covariates before and after table recalibration
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh      \
  $SAMPLE_PREFIX.dedup.realign.recal.csv
$NGS_ANALYSIS_DIR/modules/align/gatk.analyzecovariates.sh      \
  $SAMPLE_PREFIX.dedup.realign.recal.recal.csv
