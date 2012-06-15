#!/bin/bash
## 
## DESCRIPTION: Run Hiseq base calling from within BaseCalls directory
##
## USAGE: NGS.pipeline.hiseq.fastq.sh output_dir_name path/to/SampleSheet.csv
##
## OUTPUT: directory containing fastq files for each project/sample
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

OUTPUT_DIR=$1
SAMPLESHEET=$2

casava.bcl2fastq.hiseq.sh $OUTPUT_DIR $SAMPLESHEET
