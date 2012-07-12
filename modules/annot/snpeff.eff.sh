#!/bin/bash
##
## DESCRIPTION:   Run snpeff to annotate the variants in a vcf file
##
## USAGE:         snpeff.eff.sh sample.vcf [genome_version(default GRCh37.64)] ["other_snpeff_options"]
##
## OUTPUT:        sample.vcf.snpeff directory containing vcf, genes, and summary html
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Process input parameters
VCFFILE=$1
GENOME_VERSION=$2
SNPEFF_OPTIONS=$3

# Set default genome version
GENOME_VERSION=${GENOME_VERSION:=GRCh37.64}

# Format outputs
OUTPREFIX=`filter_ext $VCFFILE 1`
OUTVCF=$OUTPREFIX.snpeff$GENOME_VERSION.vcf
OUTERR=$OUTVCF.err
OUTDIR=$VCFFILE.snpeff

# Run tool
$JAVAJAR $SNPEFF                        \
  eff                                   \
  $GENOME_VERSION                       \
  -c $SNPEFF_CONFIG                     \
  -i vcf                                \
  -o vcf                                \
  -v                                    \
  $SNPEFF_OPTIONS                       \
  $VCFFILE                              \
  1> $OUTVCF                            \
  2> $OUTERR

# Create output directory to contain all output
mkdir $OUTDIR
mv                                      \
  snpEff_summary.html                   \
  snpEff_genes.txt                      \
  $OUTDIR
