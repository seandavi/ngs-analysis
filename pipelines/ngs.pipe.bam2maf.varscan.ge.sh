#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, generate a single combined TCGA maf file
##                Use grid engine using qsub
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##                Set the single_transcript flag to use only a single transcript per
##                gene.  Transcript will be selected based on the number of annotated
##                HIGH impact effect mutations.
##                If single_transcript is not set, by default will use merged transcripts.
##
## USAGE:         ngs.pipe.bam2maf.varscan.ge.sh
##                                               bamlist
##                                               ref.fa
##                                               maf_out_prefix
##                                               tumor_purity
##                                               min_cov_normal (i.e. 10)
##                                               min_cov_tumor  (i.e. 6)
##                                               snpeff_genome_version(i.e. 37.64)
##                                               [single_transcript]
##
## OUTPUT:        maf_out_prefix.maf
##                VarScan output in varscan/ directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 7 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
OUT_PRE=$3
TPURITY=$4
MINCOVN=$5
MINCOVT=$6
SNPEFFV=$7
TSINGLE=$8

# Create temporary directory
RNUM=$RANDOM
TMPDIR=tmp.bam2maf.$RNUM
mkdir $TMPDIR

# Qsub wrapper path
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh

# Run samtools mpileup
cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST) > $TMPDIR/bamfileslist
$NGS_ANALYSIS_DIR/pipelines/ngs.pipe.mpileup.ge.sh $TMPDIR/bamfileslist $REFEREN mpileup.$RNUM -Q 30

# Run varscan, annotate, and create maf files
create_dir varscan
SOMATIC_PVAL=0.05
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`

  # Run VarScan
  $QSUB varscan.$SAMPL                                                          \
        all.q                                                                   \
        1                                                                       \
        mpileup.$RNUM                                                           \
        n                                                                       \
        $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
          $BAM_N.mpileup                                                        \
          $BAM_T.mpileup                                                        \
          varscan/$SAMPL                                                        \
          $SOMATIC_PVAL                                                         \
          $TPURITY                                                              \
          $MINCOVN                                                              \
          $MINCOVT

  # Filter varscan
  $QSUB varscan.filter.$SAMPL                                                   \
        all.q                                                                   \
        1                                                                       \
        varscan.$SAMPL                                                          \
        n                                                                       \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.varscan.somatic.filter.sh          \
          varscan/$SAMPL.varscan.snp.vcf                                        \
          varscan/$SAMPL.varscan.indel.vcf                                      \
          $SOMATIC_PVAL                                                         \
          $MINCOVN

  # Annotate snp
  $QSUB snpeff.snp.$SAMPL                                                       \
        all.q                                                                   \
        1                                                                       \
        varscan.filter.$SAMPL                                                   \
        n                                                                       \
        $NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh                           \
          varscan/$SAMPL.varscan.snp.somaticfilter.somatic.vcf                  \
          $SNPEFFV

  # Annotate indel
  $QSUB snpeff.indel.$SAMPL                                                     \
        all.q                                                                   \
        1                                                                       \
        varscan.filter.$SAMPL                                                   \
        n                                                                       \
        $NGS_ANALYSIS_DIR/modules/annot/snpeff.eff.sh                           \
          varscan/$SAMPL.varscan.indel.dp10.clean.somatic.vcf                   \
          $SNPEFFV

  # Convert snp to maf
  $QSUB vcf2maf                                                                 \
        all.q                                                                   \
        1                                                                       \
        snpeff.snp.$SAMPL                                                       \
        n                                                                       \
        `which python_ngs.sh` $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf.py      \
          varscan/$SAMPL.varscan.snp.somaticfilter.somatic.snpeff.vcf           \
          $SAMPL                                                                \
          $GENE2ENTREZ                                                          \
          -e                                                                    \
          -t varscan                                                            \
          -o varscan/$SAMPL.varscan.snp.somaticfilter.somatic.snpeff.vcf.maf

  # Convert indel to maf
  $QSUB vcf2maf                                                                 \
        all.q                                                                   \
        1                                                                       \
        snpeff.indel.$SAMPL                                                     \
        n                                                                       \
        `which python_ngs.sh` $NGS_ANALYSIS_DIR/modules/somatic/vcf2maf.py      \
          varscan/$SAMPL.varscan.indel.dp10.clean.somatic.snpeff.vcf            \
          $SAMPL                                                                \
          $GENE2ENTREZ                                                          \
          -e                                                                    \
          -t varscan                                                            \
          -o varscan/$SAMPL.varscan.indel.dp10.clean.somatic.snpeff.vcf.maf
done

# If select single transcript per gene
if [ ! -z $TSINGLE ]; then
  # Select transcript per gene
  t2l=$NGS_ANALYSIS_DIR/resources/ensembl.GRCh37.67.transcripts.bed.lengths.pkl
  $QSUB select.single.transcript                                                \
        all.q                                                                   \
	1                                                                       \
	vcf2maf                                                                 \
	n                                                                       \
	$NGS_ANALYSIS_DIR/modules/util/python_ngs.sh                            \
          vcf_snpeff_count_transcript_effects.py                                \
            -l $t2l                                                             \
            -o $OUT_PRE.tcount                                                  \
            varscan/*snpeff.vcf

  # Generate maf for each sample based on the selected transcripts
  for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
    SAMPL=`echo $bamfiles | cut -f1 -d':'`
    SNPVCF=`echo varscan/$SAMPL.varscan.snp.somaticfilter.somatic.snpeff.vcf`
    INDVCF=`echo varscan/$SAMPL.varscan.indel.dp10.clean.somatic.snpeff.vcf`
    for file in '$SNPVCF $INDVCF'; do
      $QSUB vcf2maf.selected                                                    \
            all.q                                                               \
            1                                                                   \
            select.single.transcript                                            \
            n                                                                   \
            $NGS_ANALYSIS_DIR/modules/util/python_ngs.sh vcf2maf.py             \
              $file                                                             \
              $SAMPL                                                            \
              $GENE2ENTREZ                                                      \
              -s $OUT_PRE.tcount.g2t.pkl                                        \
              -t varscan                                                        \
              -o $file.maf
    done
  done
fi


exit




######################################################################################

$NGS_ANALYSIS_DIR/modules/somatic/merge_maf.sh samples varscan/*maf

# Merge all mafs
$QSUB merge.maf                                                                 \
      all.q                                                                     \
      1                                                                         \
      vcf2maf                                                                   \
      n                                                                         \
      $NGS_ANALYSIS_DIR/modules/somatic/merge_maf.sh $OUT_PRE varscan/*maf


# Generate summaries about the maf file
grep -v "3'Flank" $OUT_PRE.maf | grep -v "5'Flank" > $OUT_PRE.noflank.maf
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t pos_simple   -o $OUT_PRE.noflank.maf.summary.pos.simple
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t pos_detailed -o $OUT_PRE.noflank.maf.summary.pos.detailed
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t gene         -o $OUT_PRE.noflank.maf.summary.gene