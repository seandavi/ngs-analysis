#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.  
##              Remove analysis framework directory at the end
##              This pipeline should be run from within the BaseCalls directory
##
## USAGE: NGS.pipeline.hiseq.fastq.lite.sh
##
## OUTPUT: Directory containing the outputs of basecalls by casava software, in fastq format
##

NGS_ANALYSIS_DIR=ngs-analysis

# Run base caller script
NGS.pipeline.hiseq.fastq.sh

# Copy configureBclToFastq.pl script log to BaseCalls directory (cwd)
mv $NGS_ANALYSIS_DIR/data/configureBclToFastq.log .
rm -rf $NGS_ANALYSIS_DIR