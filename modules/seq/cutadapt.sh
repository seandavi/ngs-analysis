#!/bin/bash
##
## DESCRIPTION: Cut adapter sequences from a fastq file
## 
## USAGE: cutadapt.sh input.fastq.gz adaptor_sequence
##
## OUTPUT: input.cutadapt.fastq.gz
##

# Load bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Check correct usage
usage 2 $# $0

# Format output filenames
OUTPUTPREFIX=`filter_ext $1 2`.cutadapt
OUTPUTFILE=$OUTPUTPREFIX.fastq.gz
OUTPUTSUMMARY=$OUTPUTPREFIX.summary

# Run tool
$CUTADAPT                      \
	-o $OUTPUTFILE             \
	-b $2                      \
	-e 0.1                     \
	-q 10                      \
	-O 5                       \
	$1                         \
	>& $OUTPUTSUMMARY
