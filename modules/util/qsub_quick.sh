#!/bin/bash
## 
## DESCRIPTION:   Wrap a command for quick submission to qsub
##
## USAGE:         qsub_quick.sh command [param1 [param2 [...]]]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# Submit job to qsub
$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh quicksub \
                                               all.q    \
                                               1        \
                                               none     \
                                               n        \
                                               $@
