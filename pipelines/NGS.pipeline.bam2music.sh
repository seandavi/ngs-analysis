#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, run MuSiC
##
## USAGE:         NGS.pipeline.bam2music.sh bamlist roi_file out_dir [parallel]
##
## OUTPUT:        MuSiC output
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
OUT_DIR=$3
NUM_PARALLEL=$4
NUM_PARALLEL=${NUM_PARALLEL:=1}

# Create temporary directory
TMPDIR=tmp.bam2music.$RANDOM
mkdir $TMPDIR

#==[ Run mpileup ]=============================================================================#
P=0
for bamfile in `cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST)`; do
  samtools.mpileup.sh $bamfile "-Q 30" &
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
P=0
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  # Run VarScan, annotate, and convert to maf.  Indel vcf has formatting issues.
  varscan.somatic.vcf.sh $BAM_N.mpileup $BAM_T.mpileup varscan/$SAMPL $SOMATIC_PVAL $TUMOR_PURITY                                                        \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py varscan/$SAMPL.snp.vcf > varscan/$SAMPL.snp.somatic.vcf                           \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_somatic_filter.py varscan/$SAMPL.indel.vcf > varscan/$SAMPL.indel.somatic.vcf                       \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_clean_indel.py varscan/$SAMPL.indel.somatic.vcf > varscan/$SAMPL.indel.somatic.fixed.vcf    \
    && snpeff.eff.sh varscan/$SAMPL.snp.somatic.vcf                                                                                                      \
    && snpeff.eff.sh varscan/$SAMPL.indel.somatic.fixed.vcf                                                                                              \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf_varscan_snpeff_indel_insert_format_field.py varscan/$SAMPL.indel.somatic.fixed.snpeff.vcf           \
         > varscan/$SAMPL.indel.somatic.fixed.snpeff.format.vcf                                                                                          \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf_select_highest_transcript.py varscan/$SAMPL.indel.somatic.fixed.snpeff.format.vcf $SAMPL        \
         > varscan/$SAMPL.indel.somatic.fixed.snpeff.format.vcf.maf                                                                                      \
    && $PYTHON $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf_select_highest_transcript.py varscan/$SAMPL.snp.somatic.snpeff.vcf $SAMPL                       \
         > varscan/$SAMPL.snp.somatic.snpeff.vcf.maf &
  # Control parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done
wait

# Merge all mafs
merge_maf.sh samples varscan/*maf

#==[ Run MuSiC ]===============================================================================#

# Select genes from ensembl exons that are in maf file
grep -w -f <(cut -f1 samples.maf | sed 1d | sort -u | sed '/^$/d') $ROI_BED > roi.bed

# Compute bases covered
music.bmr.calc_covg.sh $BAMLIST roi.bed $OUT_DIR

# Compute background mutation rate
music.bmr.calc_bmr.sh $BAMLIST samples.maf roi.bed $OUT_DIR

# Compute per-gene mutation significance
# Fix erroreous counts where covered > mutations
#$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/music_fix_gene_mrs.py $OUT_DIR/gene_mrs > $OUT_DIR/gene_mrs.fixed
#music.smg.sh $OUT_DIR/gene_mrs.fixed $OUT_DIR 20
music.smg.sh $OUT_DIR/gene_mrs $OUT_DIR 20

# Mutation relation test
music.mutation_relation.sh $BAMLIST samples.maf $OUT_DIR 200

# Pfam - doesn't work
music.pfam.sh samples.maf $OUT_DIR

# Proximity analysis - need transcript name, aa changed, and nucleotide position columns in the maf file
music.proximity.sh samples.maf $OUT_DIR 10

# Compare variants against COSMIC and OMIM data - need transcript name and aa changed columns in the maf file
music.cosmic_omim.sh samples.maf $OUT_DIR


# bmr                   ...  Calculate gene coverages and background mutation rates.     
# clinical-correlation       Correlate phenotypic traits against mutated genes, or       
#                             against individual variants.                               
# cosmic-omim                Compare the amino acid changes of supplied mutations to     
#                             COSMIC and OMIM databases.                                 
# mutation-relation          Identify relationships of mutation concurrency or mutual    
#                             exclusivity in genes across cases.                         
# path-scan                  Find signifcantly mutated pathways in a cohort given a list 
#                             of somatic mutations.                                      
# pfam                       Add Pfam annotation to a MAF file.                          
# play                       Run the full suite of MuSiC tools sequentially.             
# proximity                  Perform a proximity analysis on a list of mutations.        
# smg                        Identify significantly mutated genes.                       
# survival                   Create survival plots and P-values for clinical and         
#                             mutational phenotypes.                