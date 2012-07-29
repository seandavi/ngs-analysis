#!/bin/bash
##
## DESCRIPTION:   Variant call on bam file(s)
##
## USAGE:         gatk.unifiedgenotyper.wgs.sh out_vcf input1.bam [input2.bam [...]]
##
## OUTPUT:        out_prefix.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_BAMFILES=$(($NUM_PARAMS - 1))
BAMFILES=${PARAMS[@]:1:$NUM_BAMFILES}

# Format output filenames
OUTVCF=${PARAMS[0]}
OUTLOG=$OUTVCF.log

# Format list of input bam files
INPUTBAM=''
for bamfile in $BAMFILES; do
  # Check if file exists
  if [ ! -f $bamfile ]; then
    echoerr 'File '$bamfile' does not exist. Exiting.'
    exit 1
  fi
  INPUTBAM=$INPUTBAM' -I '$bamfile
done

# Run tool
$JAVAJAR128G $GATK                                        \
  -T UnifiedGenotyper                                     \
  -l INFO                                                 \
  -R $REF                                                 \
  -nt 20                                                  \
  $INPUTBAM                                               \
  -o $OUTVCF                                              \
  -D $DBSNP_VCF                                           \
  -baq CALCULATE_AS_NECESSARY                             \
  -stand_call_conf 30.0                                   \
  -stand_emit_conf 30.0                                   \
  -mbq 17                                                 \
  -dcov 250                                               \
  -glm BOTH                                               \
  -A TransmissionDisequilibriumTest                       \
  -A ChromosomeCounts                                     \
  -A IndelType                                            \
  -A HardyWeinberg                                        \
  -A SpanningDeletions                                    \
  -A NBaseCount                                           \
  -A AlleleBalance                                        \
  -A MappingQualityZero                                   \
  -A LowMQ                                                \
  -A BaseCounts                                           \
  -A MVLikelihoodRatio                                    \
  -A InbreedingCoeff                                      \
  -A RMSMappingQuality                                    \
  -A TechnologyComposition                                \
  -A HaplotypeScore                                       \
  -A SampleList                                           \
  -A QualByDepth                                          \
  -A FisherStrand                                         \
  -A HomopolymerRun                                       \
  -A DepthOfCoverage                                      \
  -A MappingQualityZeroFraction                           \
  -A GCContent                                            \
  -A MappingQualityRankSumTest                            \
  -A ReadPosRankSumTest                                   \
  -A BaseQualityRankSumTest                               \
  &> $OUTLOG

#   -A SnpEff                                               \
#   --snpEffFile                                            \

#
# Arguments for UnifiedGenotyper:
#  -glm,--genotype_likelihoods_model <genotype_likelihoods_model>                           Genotype likelihoods 
#                                                                                           calculation model to employ -- 
#                                                                                           SNP is the default option, 
#                                                                                           while INDEL is also available 
#                                                                                           for calling indels and BOTH is 
#                                                                                           available for calling both 
#                                                                                           together (SNP|INDEL|POOLSNP|
#                                                                                           POOLINDEL|BOTH)
#  -pnrm,--p_nonref_model <p_nonref_model>                                                  Non-reference probability 
#                                                                                           calculation model to employ -- 
#                                                                                           EXACT is the default option, 
#                                                                                           while GRID_SEARCH is also 
#                                                                                           available. (EXACT|POOL)
#  -hets,--heterozygosity <heterozygosity>                                                  Heterozygosity value used to 
#                                                                                           compute prior likelihoods for 
#                                                                                           any locus
#  -pcr_error,--pcr_error_rate <pcr_error_rate>                                             The PCR error rate to be used 
#                                                                                           for computing fragment-based 
#                                                                                           likelihoods
#  -gt_mode,--genotyping_mode <genotyping_mode>                                             Specifies how to determine the 
#                                                                                           alternate alleles to use for 
#                                                                                           genotyping (DISCOVERY|
#                                                                                           GENOTYPE_GIVEN_ALLELES)
#  -out_mode,--output_mode <output_mode>                                                    Specifies which type of calls 
#                                                                                           we should output 
#                                                                                           (EMIT_VARIANTS_ONLY|
#                                                                                           EMIT_ALL_CONFIDENT_SITES|
#                                                                                           EMIT_ALL_SITES)
#  -stand_call_conf,--standard_min_confidence_threshold_for_calling                         The minimum phred-scaled 
# <standard_min_confidence_threshold_for_calling>                                           confidence threshold at which 
#                                                                                           variants not at 'trigger' 
#                                                                                           track sites should be called
#  -stand_emit_conf,--standard_min_confidence_threshold_for_emitting                        The minimum phred-scaled 
# <standard_min_confidence_threshold_for_emitting>                                          confidence threshold at which 
#                                                                                           variants not at 'trigger' 
#                                                                                          track sites should be emitted 
#                                                                                           (and filtered if less than the 
#                                                                                           calling threshold)
#  -nosl,--noSLOD                                                                           If provided, we will not 
#                                                                                           calculate the SLOD
#  -nda,--annotateNDA                                                                       If provided, we will annotate 
#                                                                                           records with the number of 
#                                                                                           alternate alleles that were 
#                                                                                           discovered (but not 
#                                                                                           necessarily genotyped) at a 
#                                                                                           given site
#  -alleles,--alleles <alleles>                                                             The set of alleles at which to 
#                                                                                           genotype when 
#                                                                                           --genotyping_mode is 
#                                                                                           GENOTYPE_GIVEN_ALLELES
#  -mbq,--min_base_quality_score <min_base_quality_score>                                   Minimum base quality required 
#                                                                                           to consider a base for calling
#  -deletions,--max_deletion_fraction <max_deletion_fraction>                               Maximum fraction of reads with 
#                                                                                           deletions spanning this locus 
#                                                                                           for it to be callable [to 
#                                                                                           disable, set to < 0 or > 1; 
#                                                                                           default:0.05]
#  -maxAlleles,--max_alternate_alleles <max_alternate_alleles>                              Maximum number of alternate 
#                                                                                           alleles to genotype
#  -minIndelCnt,--min_indel_count_for_genotyping <min_indel_count_for_genotyping>           Minimum number of consensus 
#                                                                                           indels required to trigger 
#                                                                                           genotyping run
#  -minIndelFrac,--min_indel_fraction_per_sample <min_indel_fraction_per_sample>            Minimum fraction of all reads 
#                                                                                           at a locus that must contain 
#                                                                                           an indel (of any allele) for 
#                                                                                           that sample to contribute to 
#                                                                                           the indel count for alleles
#  -indelHeterozygosity,--indel_heterozygosity <indel_heterozygosity>                       Heterozygosity for indel 
#                                                                                           calling
#  -D,--dbsnp <dbsnp>                                                                       dbSNP file
#  -comp,--comp <comp>                                                                      comparison VCF file
#  -o,--out <out>                                                                           File to which variants should 
#                                                                                           be written
#  -A,--annotation <annotation>                                                             One or more specific 
#                                                                                           annotations to apply to 
#                                                                                           variant calls
#  -XA,--excludeAnnotation <excludeAnnotation>                                              One or more specific 
#                                                                                           annotations to exclude
#  -G,--group <group>                                                                       One or more classes/groups of 
#                                                                                           annotations to apply to 
#                                                                                           variant calls


# Standard annotations in the list below are marked with a '*'.

# Available annotations for the VCF INFO field:
# TransmissionDisequilibriumTest
# *ChromosomeCounts
# IndelType
# HardyWeinberg
# *SpanningDeletions
# NBaseCount
# AlleleBalance
# *MappingQualityZero
# LowMQ
# BaseCounts
# MVLikelihoodRatio
# *InbreedingCoeff
# *RMSMappingQuality
# TechnologyComposition
# *HaplotypeScore
# SampleList
# *QualByDepth
# *FisherStrand
# SnpEff
# *HomopolymerRun
# *DepthOfCoverage
# MappingQualityZeroFraction
# GCContent
# *MappingQualityRankSumTest
# *ReadPosRankSumTest
# *BaseQualityRankSumTest


# Available annotations for the VCF FORMAT field:
# AlleleBalanceBySample
# *DepthPerAlleleBySample
# MappingQualityZeroBySample


# Available classes/groups of annotations:
# ActiveRegionBasedAnnotation
# RodRequiringAnnotation
# StandardAnnotation
# WorkInProgressAnnotation
# ExperimentalAnnotation
# RankSumTest
