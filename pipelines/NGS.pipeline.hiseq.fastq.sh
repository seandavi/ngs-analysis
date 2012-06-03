#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.
##              This pipeline should be run from within the BaseCalls directory.
##              If 2 parameters are provided, they will override the default parameters for
##              fastq output directory and sample sheet file.
##
## USAGE: NGS.pipeline.hiseq.fastq.sh [Fastq] [SampleSheet.csv]
##
## OUTPUT: Directory containing the outputs of basecalls by casava software, in fastq format
##

# Check input parameters
FASTQDIR=Fastq
SAMPLESHEET=SampleSheet.csv
if [ $# -eq 2 ]
then
  FASTQDIR=$1
  SAMPLESHEET=$2
fi

# Set source repository and new (cloned) repository paths
NGS_REPOSITORY=$HOME/src/ngs-analysis
NGS_ANALYSIS_DIR=ngs-analysis

# Clone the workspace
git clone $NGS_REPOSITORY $NGS_ANALYSIS_DIR
cd $NGS_ANALYSIS_DIR

# Run basecall
source setup.sh
casava.bcl2fastq.hiseq.sh ../ ../$FASTQDIR ../$SAMPLESHEET
