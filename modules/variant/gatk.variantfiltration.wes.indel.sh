#!/bin/bash
##
## DESCRIPTION:   Filter variants for improved call set
##
## USAGE:         gatk.variantfiltration.wes.indel.sh 
##                                                    input.vcf
##                                                    ref.fa
##
## OUTPUT:        input.filter.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input params
VCFIN=$1
REFER=$2

# Format output
OUTPRE=`filter_ext $VCFIN 1`
OUTVCF=$OUTPRE.filter.vcf
OUTLOG=$OUTVCF.log

# Run tool
$JAVAJAR2G $GATK                                                                                 \
   -T VariantFiltration                                                                          \
   -R $REFER                                                                                     \
   -V $VCFIN                                                                                     \
   -o $OUTVCF                                                                                    \
   --filterExpression "QD < 2.0"                                                                 \
   --filterExpression "ReadPosRankSum < -20.0"                                                   \
   --filterExpression "InbreedingCoeff < -0.8"                                                   \
   --filterExpression "FS > 200.0"                                                               \
   --filterName QDFilter                                                                         \
   --filterName ReadPosFilter                                                                    \
   --filterName InbreedingFilter                                                                 \
   --filterName FSFilter                                                                         \
   &> $OUTLOG


# Arguments for VariantFiltration:
#  -V,--variant <variant>                                            Input VCF file
#  --mask <mask>                                                     Input ROD mask
#  -o,--out <out>                                                    File to which variants should be written
#  -filter,--filterExpression <filterExpression>                     One or more expression used with INFO fields to 
#                                                                    filter
#  -filterName,--filterName <filterName>                             Names to use for the list of filters
#  -G_filter,--genotypeFilterExpression <genotypeFilterExpression>   One or more expression used with FORMAT 
#                                                                    (sample/genotype-level) fields to filter (see wiki 
#                                                                    docs for more info)
#  -G_filterName,--genotypeFilterName <genotypeFilterName>           Names to use for the list of sample/genotype filters 
#                                                                    (must be a 1-to-1 mapping); this name is put in the 
#                                                                    FILTER field for variants that get filtered
#  -cluster,--clusterSize <clusterSize>                              The number of SNPs which make up a cluster
#  -window,--clusterWindowSize <clusterWindowSize>                   The window size (in bases) in which to evaluate 
#                                                                    clustered SNPs
#  -maskExtend,--maskExtension <maskExtension>                       How many bases beyond records from a provided 'mask' 
#                                                                    rod should variants be filtered
#  -maskName,--maskName <maskName>                                   The text to put in the FILTER field if a 'mask' rod 
#                                                                    is provided and overlaps with a variant call
#  --missingValuesInExpressionsShouldEvaluateAsFailing               When evaluating the JEXL expressions, missing values 
#                                                                    should be considered failing the expression
#  --invalidatePreviousFilters                                       Remove previous filters applied to the VCF

