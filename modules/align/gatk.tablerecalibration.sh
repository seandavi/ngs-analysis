#!/bin/bash
##
## DESCRIPTION:   Recalibrate base quality scores
##
## USAGE:         gatk.tablerecalibration.sh sample.bam sample.bam.recaldata.csv
##
## OUTPUT:        sample.recal.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

BAMFILE=$1
RECALFILE=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $BAMFILE 1`
OUTPUTFILE=$OUTPUTPREFIX.recal.bam
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
$JAVAJAR16G $GATK                                         \
  -T TableRecalibration                                   \
  -R $REF                                                 \
  -l INFO                                                 \
  -baq RECALCULATE                                        \
  -I $BAMFILE                                             \
  -recalFile $RECALFILE                                   \
  -o $OUTPUTFILE                                          \
  -cs 8                                                   \
  -nback 7                                                \
  -solid_nocall_strategy THROW_EXCEPTION                  \
  -sMode SET_Q_ZERO                                       \
  -pQ 5                                                   \
  &> $OUTPUTLOG


#  -nt not supported