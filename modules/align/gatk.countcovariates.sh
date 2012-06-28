#!/bin/bash
##
## DESCRIPTION:   Count covariates to recalibrate base quality scores
##
## USAGE:         gatk.countcovariates.sh sample.bam
##
## OUTPUT:        sample.bam.recaldata.csv
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

BAMFILE=$1

# Format output filenames
OUTPUTFILE=$BAMFILE.recaldata.csv
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
$JAVAJAR $GATK                                            \
  -T CountCovariates                                      \
  -R $REF                                                 \
  -nt $GATK_NUM_THREADS                                   \
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
  -run_without_dbsnp_potentially_ruining_quality false    \
  -solid_nocall_strategy THROW_EXCEPTION                  \
  -sMode SET_Q_ZERO                                       \
  -standard false                                         \
  -unsorted false                                         \
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
