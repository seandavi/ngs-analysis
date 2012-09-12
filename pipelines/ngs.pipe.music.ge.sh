#!/bin/bash
## 
## DESCRIPTION:   Run MuSiC tools
## NOTE:          The reference file can cause floating point error if using human_g1k_v37.fasta from GATK resource bundle
##                because of the multiple words present in each sequence id line.  Must remove those, and provide only a
##                single-word id per sequence line.  This problem is common in other tools such as VarScan.
##
## USAGE:         ngs.pipe.music.ge.sh
##                                      bamlist
##                                      maf_file
##                                      roi_file
##                                      out_dir
##                                      ref.fa
##
## OUTPUT:        MuSiC outputs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
ROI_BED=$3
OUT_DIR=$4
REFEREN=$5

# Check files exist
assert_file_exists_w_content $BAMLIST
assert_file_exists_w_content $MAFFILE
assert_file_exists_w_content $ROI_BED
assert_dir_not_exists $OUT_DIR
assert_file_exists_w_content $REFEREN

# Create temporary directory
TMPDIR=tmp.music.$RANDOM
mkdir $TMPDIR

#==[ Run MuSiC ]===============================================================================#

# Select genes from ensembl exons that are in maf file
echo 'Generating roi subset for genes in the maf file'
#grep -w -f <(cut -f1 $MAFFILE | sed 1d | sort -u | sed '/^$/d') $ROI_BED > $TMPDIR/roi.bed
cut -f1 $MAFFILE | sed 1d | sort -u | sed '/^$/d' | $PYTHON $NGS_ANALYSIS_DIR/modules/util/grep_w_column.py - $ROI_BED -k 3 > $TMPDIR/roi.bed

# Check if tool ran successfully
assert_normal_exit_status $? "Error generating subset of roi for genes in the maf file. Exiting"

# Compute bases covered
echo 'Running bmr calc-covg'
music.bmr.calc_covg.ge.sh $BAMLIST $TMPDIR/roi.bed $OUT_DIR $REFEREN 20

# Check if tool ran successfully
assert_normal_exit_status $? "Error running calc-covg. Exiting"

# Compute background mutation rate
echo 'Running bmr calc-bmr'
music.bmr.calc_bmr.sh $BAMLIST $MAFFILE $TMPDIR/roi.bed $OUT_DIR $REFEREN 1

# Check if tool ran successfully
assert_normal_exit_status $? "Error calculating bmr. Exiting"

# Compute per-gene mutation significance
# Fix erroreous counts where covered > mutations
#$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/music_fix_gene_mrs.py $OUT_DIR/gene_mrs > $OUT_DIR/gene_mrs.fixed
#music.smg.sh $OUT_DIR/gene_mrs.fixed $OUT_DIR 20
echo 'Running smg'
music.smg.sh $OUT_DIR/gene_mrs $OUT_DIR 20

# Check if tool ran successfully
assert_normal_exit_status $? "Error computing smg. Exiting"

exit

# Merge maf gene summary with the p-values from smg
python_ngs.sh inner_join.py --header $MAFFILE.summary.gene  $OUT_DIR/smg_detailed > $MAFFILE.summary.gene.smg


# Mutation relation test
echo 'Running mutation_relation test'
music.mutation_relation.sh $BAMLIST $MAFFILE $OUT_DIR 200

# Check if tool ran successfully
assert_normal_exit_status $? "Error computing mutation_relation test. Exiting"

exit

# Pfam - doesn't work
music.pfam.sh $MAFFILE $OUT_DIR

# Proximity analysis - need transcript name, aa changed, and nucleotide position columns in the maf file
music.proximity.sh $MAFFILE $OUT_DIR 10

# Compare variants against COSMIC and OMIM data - need transcript name and aa changed columns in the maf file
music.cosmic_omim.sh $MAFFILE $OUT_DIR


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