#!/bin/bash
## 
## DESCRIPTION:   Filter out the records in the input maf file which have the 
##                Variant_Classification column corresponding to flanking regions
##                thereby resulting in an output maf file that contains variants
##                in gene block regions only
##
## USAGE:         maf.filter.flanks.sh input.maf
##
## OUTPUT:        input.geneblock.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage 1 $# $0

# Process input params
IN_MAF=$1

# Set up output filenames
OUTPRE=`filter_ext $IN_MAF 1`
FLANKS=$OUTPRE.flankterms.tmp
OUTMAF=$OUTPRE.maf

# Set up the temporary list of flanking terms
rm -f $FLANKS
echo "3'Flank" >> $FLANKS
echo "5'Flank" >> $FLANKS

# Filter
python_ngs.sh $NGS_ANALYSIS_DIR/modules/util/grep_w_column.py   \
                -v                                              \
                -k 8                                            \
                $FLANKS                                         \
                samples.maf                                     \
                > samples.geneblock.maf
