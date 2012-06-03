#!/bin/bash
##
## SET UP ANALYSIS WORKSPACE
##

# Set environment variables
export NGS_ANALYSIS_DIR=`pwd`
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/align
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/annot
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/seq
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/somatic
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/util
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/variant

# Import bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Create additional workspace directories
create_dir data
create_dir tmp
create_dir reports

# Experiment Run Information
export SAMPLESHEET=path/to/SampleSheet.csv
export READLENGTH=101
export READLENGTH_MIN=$(($READLENGTH / 2))
export PAIRED=true # [true|false]

# Set program and resource paths
source $NGS_ANALYSIS_DIR/config.sh