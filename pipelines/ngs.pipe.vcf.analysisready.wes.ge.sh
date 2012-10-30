#!/bin/bash
## 
## DESCRIPTION:   GATK recommended vcf processing pipeline for raw to analysis ready vcf
##
## USAGE:         ngs.pipe.vcf.analysisready.wes.ge.sh
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
else
  REF_FA=$B3x_REF
  HAPMAP_SITES_VCF=$B3x_HAPMAP_SITES_VCF
  OMNI_SITES_VCF=$B3x_OMNI1000_SITES_VCF
  DBSNP_VCF=$B3x_DBSNP_VCF
fi

# Make sure that input files exist with content
assert_file_exists_w_content $VCF_IN
assert_file_exists_w_content $REF_FA
assert_file_exists_w_content $HAPMAP_SITES_VCF
assert_file_exists_w_content $OMNI_SITES_VCF
assert_file_exists_w_content $DBSNP_VCF

# Set up env vars
PREFIX=`filter_ext $VCF_IN 1`
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh

# Separate snp and indel
$QSUB vcf.select.snp                                                                    \
      all.q                                                                             \
      1                                                                                 \
      None                                                                              \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.selectvariants.snp.sh                      \
        $VCF_IN                                                                         \
        $REF_FA
$QSUB vcf.select.indel                                                                  \
      all.q                                                                             \
      1                                                                                 \
      None                                                                              \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.selectvariants.indel.sh                    \
        $VCF_IN                                                                         \
        $REF_FA

# SNP variant quality score recalibration
$QSUB vcf.recal.snp                                                                     \
      all.q                                                                             \
      1                                                                                 \
      vcf.select.snp                                                                    \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.variantrecalibrator.wes.snp.sh             \
        $PREFIX.snp.vcf                                                                 \
        $REF_FA                                                                         \
        $HAPMAP_SITES_VCF                                                               \
        $OMNI_SITES_VCF                                                                 \
        $DBSNP_VCF
$QSUB vcf.gatk                                                                          \
      all.q                                                                             \
      1                                                                                 \
      vcf.recal.snp                                                                     \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.applyrecalibration.sh                      \
        $PREFIX.snp.vcf                                                                 \
        $PREFIX.snp.vcf.recal.tranches                                                  \
        $PREFIX.snp.vcf.recal                                                           \
        $REF_FA                                                                         \
        SNP

# INDEL filter
$QSUB vcf.gatk                                                                          \
      all.q                                                                             \
      1                                                                                 \
      vcf.select.indel                                                                  \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.variantfiltration.wes.indel.sh             \
        $PREFIX.indel.vcf                                                               \
        $REF_FA

# Combine the results for analysis ready vcf
$QSUB vcf.combine.snp.indel                                                             \
      all.q                                                                             \
      1                                                                                 \
      vcf.gatk                                                                          \
      n                                                                                 \
      $NGS_ANALYSIS_DIR/modules/variant/gatk.combinevariants.snp.indel.sh               \
      $PREFIX.snp.recal.vcf                                                             \
      $PREFIX.indel.filter.vcf                                                          \
      $PREFIX.analysisready.vcf                                                         \
      $REF_FA
