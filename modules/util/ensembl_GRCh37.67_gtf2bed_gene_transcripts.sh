#!/bin/bash
## 
## DESCRIPTION:   Read in Homo_sapiens.GRCh37.67.gtf from Ensembl and output data
##                in bed format.  The 4th column will contain genename_transcriptid.
##
## USAGE:         ensembl_GRCH37.67_gtf2bed_gene_transcripts.sh Homo_sapiens.GRCh37.67.gtf
##
## OUTPUT:        Homo_sapiens.GRCh37.67.gtf.gene_transcripts.bed
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 1 $# $0

# PROCESS INPUT PARAMS
INFILE=$1

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

# Sort resulting output bed file
sort -k 1,1 -k 2,2n $TMP/tmp.genes_transcripts.bed > $OUTFILE

# Remove temporary files
rm -rf $TMP
