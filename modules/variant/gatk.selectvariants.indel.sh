#!/bin/bash
##
## DESCRIPTION:   Select indels from a vcf file
##
## USAGE:         gatk.selectvariants.indel.sh input.vcf [reference]
##
## OUTPUT:        input.indel.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Process input params
VCFIN=$1
REFER=$2
REFER=${REFER:=$REF}

# Format output
OUTPRE=`filter_ext $VCFIN 1`
VCFOUT=$OUTPRE.indel.vcf
OUTLOG=$VCFOUT.log

# Run tool
$JAVAJAR2G $GATK                                          \
   -R $REFER                                              \
   -T SelectVariants                                      \
   -V $VCFIN                                              \
   -o $VCFOUT                                             \
   -selectType INDEL                                      \
   &> $OUTLOG


# Arguments for SelectVariants:
#  -V,--variant <variant>                                                       Input VCF file
#  -disc,--discordance <discordance>                                            Output variants that were not called in
#                                                                               this comparison track
#  -conc,--concordance <concordance>                                            Output variants that were also called in
#                                                                               this comparison track
#  -o,--out <out>                                                               File to which variants should be written
#  -sn,--sample_name <sample_name>                                              Include genotypes from this sample. Can be
#                                                                               specified multiple times
#  -se,--sample_expressions <sample_expressions>                                Regular expression to select many samples
#                                                                               from the ROD tracks provided. Can be
#                                                                               specified multiple times
#  -sf,--sample_file <sample_file>                                              File containing a list of samples (one per
#                                                                               line) to include. Can be specified
#                                                                               multiple times
#  -xl_sn,--exclude_sample_name <exclude_sample_name>                           Exclude genotypes from this sample. Can be
#                                                                               specified multiple times
#  -xl_sf,--exclude_sample_file <exclude_sample_file>                           File containing a list of samples (one per
#                                                                               line) to exclude. Can be specified
#                                                                               multiple times
#  -select,--select_expressions <select_expressions>                            One or more criteria to use when selecting
#                                                                               the data
#  -env,--excludeNonVariants                                                    Don't include loci found to be non-variant
#                                                                               after the subsetting procedure
#  -ef,--excludeFiltered                                                        Don't include filtered loci in the
#                                                                               analysis
#  -restrictAllelesTo,--restrictAllelesTo <restrictAllelesTo>                   Select only variants of a particular
#                                                                               allelicity. Valid options are ALL
#                                                                               (default), MULTIALLELIC or BIALLELIC (ALL|
#                                                                               BIALLELIC|MULTIALLELIC)
#  -keepOriginalAC,--keepOriginalAC                                             Don't update the AC, AF, or AN values in
#                                                                               the INFO field after selecting
#  -mv,--mendelianViolation                                                     output mendelian violation sites only
#  -mvq,--mendelianViolationQualThreshold <mendelianViolationQualThreshold>     Minimum genotype QUAL score for each trio
#                                                                               member required to accept a site as a
#                                                                               violation
#  -number,--select_random_number <select_random_number>                        Selects a number of variants at random
#                                                                               from the variant track
#  -fraction,--select_random_fraction <select_random_fraction>                  Selects a fraction (a number between 0 and
#                                                                               1) of the total variants at random from
#                                                                               the variant track
#  -fractionGenotypes,--remove_fraction_genotypes <remove_fraction_genotypes>   Selects a fraction (a number between 0 and
#                                                                               1) of the total genotypes at random from
#                                                                               the variant track and sets them to nocall
#  -selectType,--selectTypeToInclude <selectTypeToInclude>                      Select only a certain type of variants
#                                                                               from the input file. Valid types are
#                                                                               INDEL, SNP, MIXED, MNP, SYMBOLIC,
#                                                                               NO_VARIATION. Can be specified multiple
#                                                                               times
#  -IDs,--keepIDs <keepIDs>                                                     Only emit sites whose ID is found in this
#                                                                               file (one ID per line)
