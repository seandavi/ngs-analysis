#!/bin/bash
##
## DESCRIPTION:   Count covariates to recalibrate base quality scores
##
## USAGE:         gatk.countcovariates.sh sample.bam ref.fasta dbsnp.vcf [num_threads]
##
## OUTPUT:        sample.bam.recaldata.csv
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input params
BAMFILE=$1
REF=$2
DBSNP_VCF=$3
NUM_THREADS=$4
NUM_THREADS=${NUM_THREADS:=2}

# Format output filenames
OUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPREFIX.recal.csv
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
$JAVAJAR8G $GATK                                          \
  -T CountCovariates                                      \
  -R $REF                                                 \
  -nt $NUM_THREADS                                        \
  -l INFO                                                 \
  -I $BAMFILE                                             \
  -recalFile $OUTPUTFILE                                  \
  -cs 8                                                   \
  -cov ReadGroupCovariate                                 \
  -cov QualityScoreCovariate                              \
  -cov CycleCovariate                                     \
  -cov DinucCovariate                                     \
  -nback 7                                                \
  -knownSites $DBSNP_VCF                                  \
  -solid_nocall_strategy THROW_EXCEPTION                  \
  -sMode SET_Q_ZERO                                       \
  &> $OUTPUTLOG


# Available covariates: 
# DinucCovariate
# CycleCovariate
# PrimerRoundCovariate
# MappingQualityCovariate
# HomopolymerCovariate
# GCContentCovariate
# PositionCovariate
# MinimumNQSCovariate
# ContextCovariate
# ReadGroupCovariate
# QualityScoreCovariate
