#!/bin/bash
##
## Clone the analysis workspace and generate fastq files
##

ANALYSIS_DIR=ngs-analysis
git clone $HOME/src/ngs-analysis $ANALYSIS_DIR
cd $ANALYSIS_DIR

source setup.sh
casava.bcl2fastq.hiseq.sh ../ ../Fastq ../SampleSheet.csv
