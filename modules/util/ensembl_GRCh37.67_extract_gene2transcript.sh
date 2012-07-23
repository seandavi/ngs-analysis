#!/bin/bash
## 
## DESCRIPTION:   Read in Homo_sapiens.GRCh37.67.gtf from Ensembl and extract
##                mapping of gene names and transcript ids
##                Output format: gene_name, gene_id, transcript_id
##
## USAGE:         ensembl_GRCH37.67_extract_gene2transcript.sh Homo_sapiens.GRCh37.67.gtf
##
## OUTPUT:        Homo_sapiens.GRCh37.67.gtf.gene2transcript
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 1 $# $0

INFILE=$1
OUTFILE=$INFILE.gene2transcript

cut -f1,9 Homo_sapiens.GRCh37.67.gtf | sed 's/\"/\t/g' | awk -F '\t' 'BEGIN{OFS="\t";}{print $9,$3,$5;}' | sort -u > $OUTFILE