#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.
##
## USAGE: NGS.pipeline.hiseq.fastq.sh
##
## OUTPUT: Directory containing the outputs of basecalls by casava software, in fastq format
##


NGS_REPOSITORY=$HOME/src/ngs-analysis
ANALYSIS_DIR=ngs-analysis
git clone $NGS_REPOSITORY $ANALYSIS_DIR
cd $ANALYSIS_DIR

source setup.sh
casava.bcl2fastq.hiseq.sh ../ ../Fastq ../SampleSheet.csv
