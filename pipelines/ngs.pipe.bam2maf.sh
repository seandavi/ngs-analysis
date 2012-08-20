#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, generatea  single combined TCGA maf file
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##
## USAGE:         ngs.pipe.bam2maf.sh bamlist ref.fa maf_out_prefix [parallel]
##
## OUTPUT:        maf_out_prefix.maf
##                VarScan output in varscan/ directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
OUT_PRE=$3
NUM_PARALLEL=$4
NUM_PARALLEL=${NUM_PARALLEL:=1}

# Create temporary directory
TMPDIR=tmp.bam2maf.$RANDOM
mkdir $TMPDIR

#==[ Run mpileup ]=============================================================================#
P=0
for bamfile in `cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST)`; do
  samtools.mpileup.sh $bamfile $REFEREN "-Q 30" &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done
wait

#==[ Run VarScan and convert results to maf format ]===========================================#
mkdir varscan
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid
P=0
# VarScan
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  varscan.somatic.vcf.sh $BAM_N.mpileup $BAM_T.mpileup varscan/$SAMPL $SOMATIC_PVAL $TUMOR_PURITY &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done
wait

# Convert varscan output vcf files to maf
P=0
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  # SNP
  $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.snp.sh $SAMPL varscan/$SAMPL.snp.vcf &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
  # INDEL
  $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.indel.sh $SAMPL varscan/$SAMPL.indel.vcf &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done
wait

# Merge all mafs
merge_maf.sh $OUT_PRE varscan/*maf
