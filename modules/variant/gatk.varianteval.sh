#!/bin/bash
##
## DESCRIPTION:   Evaluate list of variants in vcf file(s)
##
## USAGE:         gatk.varianteval.sh
##                                    ref.fa
##                                    out_prefix
##                                    input1.vcf
##                                    [input2.vcf [...]]
##
## OUTPUT:        input.filter.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input params
PARAMS=($@)
NUMPAR=${#PARAMS[@]}
REF_FA=${PARAMS[0]}
OUTPRE=${PARAMS[1]}
NUMVCF=$(($NUMPAR - 2))
VCFSIN=${PARAMS[@]:2:$NUMVCF}

INPUTVCFS=''
for file in $VCFSIN; do
  # Check if file exists
  #assert_file_exists_w_content $file
  SAMPL=`filter_ext $file 1`
  INPUTVCFS=$INPUTVCFS' --eval:'$SAMPL' '$file
done

# Format output
OUTPUT=$OUTPRE.varianteval.report
OUTLOG=$OUTPUT.log

# Run tool
`javajar 2g` $GATK     \
   -T VariantEval      \
   -R $RE_FA           \
   -o $OUTPUT          \
   $INPUTVCFS          \
   &> $OUTLOG

# Arguments for VariantEval:
#  -eval,--eval <eval>                                                        Input evaluation file(s)
#  -o,--out <out>                                                             An output file created by the walker.  Will 
#                                                                             overwrite contents if file exists
#  -comp,--comp <comp>                                                        Input comparison file(s)
#  -D,--dbsnp <dbsnp>                                                         dbSNP file
#  -gold,--goldStandard <goldStandard>                                        Evaluations that count calls at sites of 
#                                                                             true variation (e.g., indel calls) will use 
#                                                                             this argument as their gold standard for 
#                                                                             comparison
#  -ls,--list                                                                 List the available eval modules and exit
#  -select,--select_exps <select_exps>                                        One or more stratifications to use when 
#                                                                             evaluating the data
#  -selectName,--select_names <select_names>                                  Names to use for the list of stratifications 
#                                                                             (must be a 1-to-1 mapping)
#  -sn,--sample <sample>                                                      Derive eval and comp contexts using only 
#                                                                             these sample genotypes, when genotypes are 
#                                                                             available in the original context
#  -knownName,--known_names <known_names>                                     Name of ROD bindings containing variant 
#                                                                             sites that should be treated as known when 
#                                                                             splitting eval rods into known and novel 
#                                                                             subsets
#  -ST,--stratificationModule <stratificationModule>                          One or more specific stratification modules 
#                                                                             to apply to the eval track(s) (in addition 
#                                                                             to the standard stratifications, unless -noS 
#                                                                             is specified)
#  -noST,--doNotUseAllStandardStratifications                                 Do not use the standard stratification 
#                                                                             modules by default (instead, only those that 
#                                                                             are specified with the -S option)
#  -EV,--evalModule <evalModule>                                              One or more specific eval modules to apply 
#                                                                             to the eval track(s) (in addition to the 
#                                                                             standard modules, unless -noEV is specified)
#  -noEV,--doNotUseAllStandardModules                                         Do not use the standard modules by default 
#                                                                             (instead, only those that are specified with 
#                                                                             the -EV option)
#  -mpq,--minPhaseQuality <minPhaseQuality>                                   Minimum phasing quality
#  -mvq,--mendelianViolationQualThreshold <mendelianViolationQualThreshold>   Minimum genotype QUAL score for each trio 
#                                                                             member required to accept a site as a 
#                                                                             violation. Default is 50.
#  -aa,--ancestralAlignments <ancestralAlignments>                            Fasta file with ancestral alleles
#  -strict,--requireStrictAlleleMatch                                         If provided only comp and eval tracks with 
#                                                                             exactly matching reference and alternate 
#                                                                             alleles will be counted as overlapping
#  -keepAC0,--keepAC0                                                         If provided, modules that track polymorphic 
#                                                                             sites will not require that a site have AC > 
#                                                                             0 when the input eval has genotypes
#  -mergeEvals,--mergeEvals                                                   If provided, all -eval tracks will be merged 
#                                                                             into a single eval track
#  -stratIntervals,--stratIntervals <stratIntervals>                          File containing tribble-readable features 
#                                                                             for the IntervalStratificiation
#  -knownCNVs,--knownCNVs <knownCNVs>                                         File containing tribble-readable features 
#                                                                             describing a known list of copy number 
#                                                                             variants

                                                 