#!/bin/bash
##
## DESCRIPTION:   Combine vcf files
##
## USAGE:         gatk.combinevariants.snp.indel.sh 
##                                                   input.snp.vcf
##                                                   input.indel.vcf
##                                                   output.vcf
##                                                   ref.fa
##
## OUTPUT:        output.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

# Process input params
VCFSNP=$1
VCFIND=$2
OUTVCF=$3
REFERE=$4

# Format output
OUTLOG=$OUTVCF.log

# Run tool
$JAVAJAR2G $GATK                                                                                 \
   -T CombineVariants                                                                            \
   -R $REFERE                                                                                    \
   --variant:snp   $VCFSNP                                                                       \
   --variant:indel $VCFIND                                                                       \
   -o $OUTVCF                                                                                    \
   -genotypeMergeOptions PRIORITIZE                                                              \
   -priority snp,indel                                                                           \
   &> $OUTLOG


# Arguments for CombineVariants:
#  -V,--variant <variant>                                                            Input VCF file
#  -o,--out <out>                                                                    File to which variants should be 
#                                                                                    written
#  -genotypeMergeOptions,--genotypemergeoption <genotypemergeoption>                 Determines how we should merge 
#                                                                                    genotype records for samples shared 
#                                                                                    across the ROD files (UNIQUIFY|
#                                                                                    PRIORITIZE|UNSORTED|REQUIRE_UNIQUE)
#  -filteredRecordsMergeType,--filteredrecordsmergetype <filteredrecordsmergetype>   Determines how we should handle 
#                                                                                    records seen at the same site in the 
#                                                                                    VCF, but with different FILTER fields 
#                                                                                    (KEEP_IF_ANY_UNFILTERED|
#                                                                                    KEEP_IF_ALL_UNFILTERED|
#                                                                                    KEEP_UNCONDITIONAL)
#  -priority,--rod_priority_list <rod_priority_list>                                 A comma-separated string describing 
#                                                                                    the priority ordering for the 
#                                                                                    genotypes as far as which record gets 
#                                                                                    emitted
#  -printComplexMerges,--printComplexMerges                                          Print out interesting sites requiring 
#                                                                                    complex compatibility merging
#  -filteredAreUncalled,--filteredAreUncalled                                        If true, then filtered VCFs are 
#                                                                                    treated as uncalled, so that filtered 
#                                                                                    set annotations don't appear in the 
#                                                                                    combined VCF
#  -minimalVCF,--minimalVCF                                                          If true, then the output VCF will 
#                                                                                    contain no INFO or genotype FORMAT 
#                                                                                    fields
#  -setKey,--setKey <setKey>                                                         Key used in the INFO key=value tag 
#                                                                                    emitted describing which set the 
#                                                                                    combined VCF record came from
#  -assumeIdenticalSamples,--assumeIdenticalSamples                                  If true, assume input VCFs have 
#                                                                                    identical sample sets and disjoint 
#                                                                                    calls
#  -minN,--minimumN <minimumN>                                                       Combine variants and output site only 
#                                                                                    if the variant is present in at least 
#                                                                                    N input files.
#  -suppressCommandLineHeader,--suppressCommandLineHeader                            If true, do not output the header 
