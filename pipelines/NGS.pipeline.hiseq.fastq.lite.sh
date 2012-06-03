#!/bin/bash
##
## Generate fastq files without cloning the framework workspace
##

NGS_REPOSITORY=$HOME/src/ngs-analysis

source $NGS_REPOSITORY/config.sh
$NGS_REPOSITORY/modules/seq/casava.bcl2fastq.hiseq.sh ../ ../Fastq ../SampleSheet.csv
