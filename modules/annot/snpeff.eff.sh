#!/bin/bash
##
## DESCRIPTION:   Run snpeff to annotate the variants in a vcf file
##
## USAGE:         snpeff.eff.sh sample.vcf [genome_version(default GRCh37.64) ["other_snpeff_options"]]
##
## OUTPUT:        sample.snpeff.vcf
##                sample.snpeff.snpEff_summary.html
##                sample.snpeff.snpEff_summary.genes.txt
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Process input parameters
VCFFILE=$1
GENOME_VERSION=$2
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_OPTIONS=$(($NUM_PARAMS - 2))
SNPEFF_OPTIONS=${PARAMS[@]:2:$NUM_OPTIONS}

# Set default genome version
GENOME_VERSION=${GENOME_VERSION:=GRCh37.64}

# If only genome version is provided, prefix GRCh
if [[ $GENOME_VERSION =~ '^[0-9]{2}\.[0-9]{2}$' ]]; then
  GENOME_VERSION='GRCh'$GENOME_VERSION
fi

# Format outputs
OUTPREFIX=`filter_ext $VCFFILE 1`
OUTVCF=$OUTPREFIX.snpeff.vcf
OUTSTATS=$OUTPREFIX.snpeff.snpEff_summary.html
OUTERR=$OUTVCF.err
#OUTDIR=$OUTPREFIX.snpeff

# Run tool
`javajar 4g` $SNPEFF                    \
  eff                                   \
  $GENOME_VERSION                       \
  -c $SNPEFF_CONFIG                     \
  -i vcf                                \
  -o vcf                                \
  -s $OUTSTATS                          \
  -v                                    \
  $SNPEFF_OPTIONS                       \
  $VCFFILE                              \
  1> $OUTVCF                            \
  2> $OUTERR

# # Check if tool ran successfully
# assert_normal_exit_status $? "SNPEff exited with error"

# # Create output directory to contain all output
# mkdir $OUTDIR
# mv                                      \
#   $OUTSTATS                             \
#   snpEff_genes.txt                      \
#   $OUTDIR
