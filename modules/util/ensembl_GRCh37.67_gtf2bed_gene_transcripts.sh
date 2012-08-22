#!/bin/bash
## 
## DESCRIPTION:   Read in Homo_sapiens.GRCh37.67.gtf from Ensembl and output data
##                in bed format.  The 4th column will contain genename_transcriptid.
##
## USAGE:         ensembl_GRCH37.67_gtf2bed_gene_transcripts.sh Homo_sapiens.GRCh37.67.gtf [num_parallel]
##
## OUTPUT:        Homo_sapiens.GRCh37.67.gtf.gene_transcripts.bed
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
OUTFILE=$INFILE.gene_transcripts.bed

# Create temporary directory
TMP=tmp.gtf2bed_gene_transcripts.$RANDOM
mkdir $TMP

# Convert first to rough bed format
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/ensembl_GRCh37.67_gtf2bed.py $INFILE > $TMP/tmp.bed

# Extract gene names and transcript ids to put as the 4th column
paste -d _  <(cut -f4 $TMP/tmp.bed | cut -f8 -d'"') <(cut -f4 $TMP/tmp.bed | cut -f4 -d'"') > $TMP/col.4

# Create the bed file
paste <(cut -f1,2,3 $TMP/tmp.bed) $TMP/col.4 > $TMP/tmp.genes_transcripts.bed

# Loop through gene names, and generate merged bed files
sort -u $TMP/col.4 > $TMP/tmp.genenames
P=0
for gene in `cat $TMP/tmp.genenames`; do
  awk '{ if($4=="'$gene'"){print $0} }' $TMP/tmp.genes_transcripts.bed    \
    | sort -k 1,1 -k 2,2n                                                 \
    | $BEDTOOLS_PATH/mergeBed -i stdin                                    \
    | sed 's/$/\t'$gene'/'                                                \
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
rm -f $TMP/tmp.gene_transcripts.merged.bed
for gene in `cat $TMP/tmp.genenames`; do
  cat $TMP/tmp.separate.$gene.merged.bed >> $TMP/tmp.gene_transcripts.merged.bed
done

# Sort resulting output bed file
sort -k 1,1 -k 2,2n $TMP/tmp.gene_transcripts.merged.bed > $OUTFILE

# Remove temporary files
rm -rf $TMP
