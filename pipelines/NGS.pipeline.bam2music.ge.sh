#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, run MuSiC.  Use grid engine using qsub
##
## USAGE:         NGS.pipeline.bam2music.ge.sh bamlist roi_file out_dir
##
## OUTPUT:        MuSiC output
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
OUT_DIR=$3

# Create temporary directory
TMPDIR=tmp.bam2music.$RANDOM
mkdir $TMPDIR

# Run samtools mpileup
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
for bamfile in `cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST)`; do
  $QSUB mpileup.$SAMPL                                                          \
        all.q                                                                   \
        1                                                                       \
        1G                                                                      \
        none                                                                    \
        $NGS_ANALYSIS_DIR/modules/align/samtools.mpileup.sh $bamfile "-Q 30"
done

# Run varscan, annotate, and create maf files
mkdir varscan
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`

  # Run VarScan
  $QSUB varscan.$SAMPL                                                          \
        all.q                                                                   \
        1                                                                       \
        32G                                                                     \
        mpileup.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
          $BAM_N.mpileup                                                        \
          $BAM_T.mpileup                                                        \
          varscan/$SAMPL                                                        \
          $SOMATIC_PVAL                                                         \
          $TUMOR_PURITY

  # Convert varscan output to maf
  $QSUB varscan.vcf2maf.$SAMPL                                                  \
        all.q                                                                   \
        1                                                                       \
        1G                                                                      \
        varscan.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/pipelines/NGS.pipeline.varscan.vcf2maf.sh             \
          varscan/$SAMPL.snp.vcf                                                \
          varscan/$SAMPL.indel.vcf
done


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