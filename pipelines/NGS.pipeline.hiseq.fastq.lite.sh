#!/bin/bash
##
## DESCRIPTION: Clone the analysis framework workspace and generate fastq files.  
##              Remove analysis framework directory at the end
##
## USAGE: NGS.pipeline.hiseq.fastq.lite.sh
##
## OUTPUT: Directory containing the outputs of basecalls by casava software, in fastq format
##


NGS.pipeline.hiseq.fastq.sh
rm -rf ngs-analysis