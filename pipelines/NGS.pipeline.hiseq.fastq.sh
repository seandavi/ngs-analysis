#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.
##              This pipeline should be run from within the BaseCalls directory
##
## USAGE: NGS.pipeline.hiseq.fastq.sh
##
## OUTPUT: Directory containing the outputs of basecalls by casava software, in fastq format
##


NGS_REPOSITORY=$HOME/src/ngs-analysis
NGS_ANALYSIS_DIR=ngs-analysis

# Clone the workspace
git clone $NGS_REPOSITORY $NGS_ANALYSIS_DIR
cd $NGS_ANALYSIS_DIR

# Run basecall
source setup.sh
casava.bcl2fastq.hiseq.sh ../ ../Fastq ../SampleSheet.csv
