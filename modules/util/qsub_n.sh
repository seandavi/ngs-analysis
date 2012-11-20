#!/bin/bash
## 
## DESCRIPTION:   Wrap a command for quick submission to qsub for n parallele processes
##
## USAGE:         qsub_n.sh num_procs command [param1 [param2 [...]]]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUMPP=${PARAMS[0]}
LEN_COMMD=$(($NUM_PARAMS - 1))
COMMD=${PARAMS[@]:1:$LEN_COMMD}


# Submit job to qsub
$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh qsub_n   \
                                               all.q    \
                                               $NUMPP   \
                                               none     \
                                               n        \
                                               $COMMD
