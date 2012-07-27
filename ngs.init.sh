#!/bin/bash
##
## Set up ngs-analysis initial settings and paths
##

#=====================================================================================
# Set path to ngs-analysis directory

export NGS_ANALYSIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#=====================================================================================
# Set paths and other config options

export NGS_ANALYSIS_CONFIG=$NGS_ANALYSIS_DIR/ngs.config.sh
export PATH=$NGS_ANALYSIS_DIR/pipelines:$NGS_ANALYSIS_DIR/modules/util:$PATH
export PYTHONPATH=$PYTHONPATH:$NGS_ANALYSIS_DIR/lib/python