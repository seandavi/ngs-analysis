#!/bin/bash
## 
## DESCRIPTION:   Read in refGene.bed , an exome bed file exported from UCSC genome browser, 
##                and map the 4th column to have only gene names.  Merge all the 
##                transcripts for that gene.
##
## USAGE:         ucsc_refGene_exome_bed_merged_transcripts.sh refGene.bed [num_parallel]
##
## OUTPUT:        refFlat.txt.merged_transcripts.bed
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# PROCESS INPUT PARAMS
INFILE=$1
NUM_PARALLEL=$2
NUM_PARALLEL=${NUM_PARALLEL:=1}

# FORMAT OUTPUT
OUTFILE=$INFILE.merged_transcripts.bed

# Create temporary directory
TMP=tmp.refflat2bed_merged_transcripts.$RANDOM
mkdir $TMP

# Extract only refseq ids in the 4th column
paste <(cut -f1-3 $INFILE) <(cut -f4 $INFILE | cut -f1-2 -d'_') > $TMP/tmp.bed

# Substitute gene names for transcipt ids
$PYTHON $NGS_ANALYSIS_DIR/modules/util/vsub.py      \
  $TMP/tmp.bed                                      \
  $NGS_ANALYSIS_DIR/resources/gene2refid            \
  --f1-column-a 3                                   \
  --f1-column-b 3                                   \
  --f2-column-a 1                                   \
  --f2-column-b 0                                   \
  > $TMP/tmp.genes.bed

# Extract gene names
cut -f4 $TMP/tmp.genes.bed | sort -u > $TMP/tmp.genes.bed.genenames

# Loop through gene names, and generate merged bed files
P=0
for gene in `cat $TMP/tmp.genes.bed.genenames`; do
  awk '{ if($4=="'$gene'"){print $0} }' $TMP/tmp.genes.bed    \
    | sort -k 1,1 -k 2,2n                                     \
    | $BEDTOOLS_PATH/mergeBed -i stdin                        \
    | sed 's/$/\t'$gene'/'                                    \
    > $TMP/tmp.separate.$gene.merged.bed &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done
wait

# Concatenate all merged gene bed files
rm -f $TMP/tmp.genes.merged.bed
for gene in `cat $TMP/tmp.genes.bed.genenames`; do
  cat $TMP/tmp.separate.$gene.merged.bed >> $TMP/tmp.genes.merged.bed
done

# Sort resulting output bed file
sort -k 1,1 -k 2,2n $TMP/tmp.genes.merged.bed > $OUTFILE

# Remove temporary files
rm -rf $TMP
