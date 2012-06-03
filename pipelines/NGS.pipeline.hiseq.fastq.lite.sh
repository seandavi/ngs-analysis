#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.  
##              Remove analysis framework directory at the end.
##              This pipeline should be run from within the BaseCalls directory.
##              If 2 parameters are provided, they will override the default parameters for
##              fastq output directory and sample sheet file.
##
## USAGE: NGS.pipeline.hiseq.fastq.lite.sh [Fastq] [SampleSheet.csv]
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

# Analysis framework directory to be deleted after basecalling
NGS_ANALYSIS_DIR=ngs-analysis

# Run base caller script
NGS.pipeline.hiseq.fastq.sh $FASTQDIR $SAMPLESHEET

# Copy configureBclToFastq.pl script log to BaseCalls directory (cwd)
mv $NGS_ANALYSIS_DIR/data/configureBclToFastq.log .
rm -rf $NGS_ANALYSIS_DIR