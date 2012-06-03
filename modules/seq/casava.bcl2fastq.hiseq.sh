#!/bin/bash
##
## DESCRIPTION: Generate fastq files from Hiseq experiment results
## 
## USAGE: casava.bcl2fastq.hiseq.sh basecalls_dir output_dir_name path/to/SampleSheet.csv
##
## OUTPUT: output_dir_name containing fastq files for each project/sample
##

# Load bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Check correct usage
usage 3 $# $0

BASECALLS_DIR=$1
OUTPUT_DIR=$2
SAMPLESHEET=$3

# Check to make sure that basecalls_dir exists
if [ ! -d $BASECALLS_DIR ]; then
  echoerr "Error: BaseCalls directory $BASECALLS_DIR does not exist!"
  exit 1
fi

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
$BCL2FASTQ                                                 \
  --input-dir $BASECALLS_DIR                               \
  --intensities-dir $BASECALLS_DIR/../                     \
  --positions-format .clocs                                \
  --fastq-cluster-count 900000000                          \
  --sample-sheet $SAMPLESHEET                              \
  --output-dir $OUTPUT_DIR >& data/configureBclToFastq.log


# Go into output directory, and run the makefile
cd $OUTPUT_DIR
nohup make -j $BCL2FASTQ_NUM_THREADS
