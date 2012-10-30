#!/bin/bash
## 
## DESCRIPTION:   GATK recommended vcf processing pipeline for raw to analysis ready vcf
##
## USAGE:         ngs.pipe.vcf.analysisready.wgs.ge.sh
##                                                     input.vcf
##                                                     (HG|B3x)
##
## OUTPUT:        input.analysisready.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input params
VCF_IN=$1
RESOURCE_T=$2

# Set resource vars
if [ $RESOURCE_T = 'HG' ]; then
  REF_FA=$HG_REF
  HAPMAP_SITES_VCF=$HG_HAPMAP_SITES_VCF
  OMNI_SITES_VCF=$HG_OMNI1000_SITES_VCF
  DBSNP_VCF=$HG_DBSNP_VCF
  MILLS_VCF=$HG_MILLS_INDELS_SITES_VCF
else
  REF_FA=$B3x_REF
  HAPMAP_SITES_VCF=$B3x_HAPMAP_SITES_VCF
  OMNI_SITES_VCF=$B3x_OMNI1000_SITES_VCF
  DBSNP_VCF=$B3x_DBSNP_VCF
  MILLS_VCF=$B3x_MILLS_INDELS_SITES_VCF
fi

# Make sure that input files exist with content
assert_file_exists_w_content $VCF_IN
assert_file_exists_w_content $REF_FA
assert_file_exists_w_content $HAPMAP_SITES_VCF
assert_file_exists_w_content $OMNI_SITES_VCF
assert_file_exists_w_content $DBSNP_VCF
assert_file_exists_w_content $MILLS_VCF

# Set up env vars
PREFIX=`filter_ext $VCF_IN 1`
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh

# Create symbolic link for parallel recalibration step
ln -s $VCF_IN $PREFIX.snp.vcf
ln -s $VCF_IN $PREFIX.indel.vcf

# SNP variant quality score recalibration
$QSUB vcf.recalsnp                                                                      \
      all.q                                                                             \
      1                                                                                 \
      none                                                                              \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.variantrecalibrator.wgs.snp.sh             \
        $PREFIX.snp.vcf                                                                 \
        $REF_FA                                                                         \
        $HAPMAP_SITES_VCF                                                               \
        $OMNI_SITES_VCF                                                                 \
        $DBSNP_VCF

# SNP apply recal to input vcf
$QSUB vcf.applysnp.recalindel                                                           \
      all.q                                                                             \
      1                                                                                 \
      vcf.recalsnp                                                                      \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.applyrecalibration.sh                      \
        $PREFIX.snp.vcf                                                                 \
        $PREFIX.snp.recal.tranches                                                      \
        $PREFIX.snp.recal                                                               \
        $REF_FA                                                                         \
        SNP

# INDEL variant quality score recalibration
$QSUB vcf.applysnp.recalindel                                                           \
      all.q                                                                             \
      1                                                                                 \
      none                                                                              \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.variantrecalibrator.wgs.indel.sh           \
        $$PREFIX.indel.vcf                                                              \
        $REF_FA                                                                         \
        $MILLS_VCF

# INDEL apply recal to input vcf
$QSUB vcf.applyindel                                                                    \
      all.q                                                                             \
      1                                                                                 \
      vcf.applysnp.recalindel                                                           \
      n                                                                                 \
      $NGS_ANALYLSIS_DIR/modules/variant/gatk.applyrecalibration.sh                     \
        $PREFIX.snp.recal.vcf                                                           \
        $PREFIX.indel.recal.tranches                                                    \
        $PREFIX.indel.recal                                                             \
        $REF_FA                                                                         \
        INDEL

# Rename the final output vcf file
$QSUB vcf.rename.output                                                                 \
      all.q                                                                             \
      1                                                                                 \
      vcf.applyindel                                                                    \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/util/bash_wrapper.sh                                    \
                                                     mv                                 \
                                                     $PREFIX.snp.recal.recal.vcf        \
                                                     $PREFIX.analysisready.vcf
