#!/bin/bash
## 
## DESCRIPTION:   Generate summaries from TCGA maf file
##
## USAGE:         ngs.pipe.maf.summarize.ge.sh input.maf
##
## OUTPUT:        input.maf.summary.pos.simple
##                input.maf.summary.pos.detailed
##                input.maf.summary.gene
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

# Process input params
IN_MAF=$1

# Set output filenames
OUTPRE=$IN_MAF

# Run summaries
QSUB_WRAPPER=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
PYTHON=$NGS_ANALYSIS_DIR/modules/util/python_ngs.sh
$QSUB_WRAPPER maf.summary.pos.simple                                           \
              all.q                                                            \
              1                                                                \
              1G                                                               \
              none                                                             \
              n                                                                \
              $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/maf_summaries.py       \
                        $IN_MAF                                                \
                        -t pos_simple                                          \
                        -o $OUTPRE.summary.pos.simple

$QSUB_WRAPPER maf.summary.pos.detailed                                         \
              all.q                                                            \
              1                                                                \
              1G                                                               \
              none                                                             \
              n                                                                \
              $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/maf_summaries.py       \
                        $IN_MAF                                                \
                        -t pos_detailed                                        \
                        -o $OUTPRE.summary.pos.detailed

$QSUB_WRAPPER maf.summary.pos.gene                                             \
              all.q                                                            \
              1                                                                \
              1G                                                               \
              none                                                             \
              n                                                                \
              $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/maf_summaries.py       \
                        $IN_MAF                                                \
                        -t gene                                                \
                        -o $OUTPRE.summary.gene
