#!/bin/bash
##
## DESCRIPTION:   Plot residual error vs covariates
##
## USAGE:         gatk.analyzecovariates.sh sample.recaldata.csv
##
## OUTPUT:        sample.recaldata.analyzecovariates/
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

RECALFILE=$1

# Format output filenames
OUTPUTPREFIX=`filter_ext $RECALFILE 1`
OUTPUTDIR=$OUTPUTPREFIX.analyzecovariates
OUTPUTLOG=$OUTPUTDIR.log
OUTPUTERR=$OUTPUTDIR.err

# Run tool
$JAVAJAR $GATK_ANALYZECOVARIATES                  \
  -recalFile $RECALFILE                           \
  -outputDir $OUTPUTDIR                           \
  -l INFO                                         \
  -numRG -1                                       \
  -ignoreQ 5                                      \
  -maxQ 50                                        \
  -maxHist 0                                      \
  -log $OUTPUTLOG                                 \
  &> $OUTPUTERR
