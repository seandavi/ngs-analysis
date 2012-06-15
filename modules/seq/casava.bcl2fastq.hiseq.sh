#!/bin/bash
##
## DESCRIPTION: Generate fastq files from Hiseq experiment results
##              Must be run from within the BaseCalls directory
## 
## USAGE: casava.bcl2fastq.hiseq.sh output_dir_name path/to/SampleSheet.csv
##
## OUTPUT: directory containing fastq files for each project/sample
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

OUTPUT_DIR=$1
SAMPLESHEET=$2

# Check to make sure that output_directory_name doesn't already exist
if [ -d $OUTPUT_DIR ]; then
  echoerr "Error: Output directory $OUTPUT_DIR already exists"
  exit 1
fi

# Check to make sure that samplesheet exists
if [ ! -f $SAMPLESHEET ]; then
  echoerr "Error: Sample sheet file $SAMPLESHEET does not exist!"
  exit 1
fi


# Setup basecalling makefile
BASECALLS_DIR=$PWD
$BCL2FASTQ                                                 \
  --input-dir $BASECALLS_DIR                               \
  --intensities-dir $BASECALLS_DIR/../                     \
  --positions-format .clocs                                \
  --fastq-cluster-count 900000000                          \
  --sample-sheet $SAMPLESHEET                              \
  --output-dir $OUTPUT_DIR >& $BASECALLS_DIR/configureBclToFastq.log


# Go into output directory, and run the makefile
cd $OUTPUT_DIR
nohup make -j $BCL2FASTQ_NUM_THREADS
