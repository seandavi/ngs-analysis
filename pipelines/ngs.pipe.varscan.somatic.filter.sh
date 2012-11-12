#!/bin/bash
## 
## DESCRIPTION:   Given a pair of varscan output vcf files, filter the results to remove false positives
##
## USAGE:         ngs.pipe.varscan.somatic.filter.sh
##                                                   sample.varscan.snp.vcf
##                                                   sample.varscan.indel.vcf
##                                                   somatic-p-value           (default 0.05)
##                                                   min-coverage              (default 10)
##
##
## OUTPUT:        sample.varscan.snp.somaticfilter.somatic.vcf
##                sample.varscan.indel.dp10.clean.somatic.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
SNPVCF=$1
INDVCF=$2
S_PVAL=$3
MINCOV=$4

# Check to make sure that input files exist
assert_file_exists_w_content $SNPVCF
assert_file_exists_w_content $INDVCF

# Set default param values
if [ -z "$S_PVAL" ]; then
  S_PVAL=0.05
fi
if [ -z "$MINCOV" ]; then
  MINCOV=10
fi

# Set up output filenames
PREFIX_SNP=`filter_ext $SNPVCF 1`
PREFIX_IND=`filter_ext $INDVCF 1`


# Filter indel for depth
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_IND.vcf                                               \
          --min-dp-tumor $MINCOV                                        \
          --min-dp-normal $MINCOV                                       \
          -o $PREFIX_IND.dp10.vcf

# Run somaticFilter
varscan.somaticfilter.vcf.sh $SNPVCF $PREFIX_IND.dp10.vcf $S_PVAL $MINCOV

# Filter snps for somatic
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_SNP.somaticfilter.vcf                                 \
          --min-dp-tumor $MINCOV                                        \
          --min-dp-normal $MINCOV                                       \
          --somatic-p-val $S_PVAL                                       \
          -t somatic                                                    \
          -o $PREFIX_SNP.somaticfilter.somatic.vcf

# Clean up indel file
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_clean_indel.py    \
          $PREFIX_IND.dp10.vcf                                          \
          -o $PREFIX_IND.dp10.clean.vcf

# Filter indel for somatic
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py         \
          $PREFIX_IND.dp10.clean.vcf                                    \
          -t somatic                                                    \
          --min-dp-tumor $MINCOV                                        \
          --min-dp-normal $MINCOV                                       \
          --somatic-p-val $S_PVAL                                       \
          -o $PREFIX_IND.dp10.clean.somatic.vcf
