#!/bin/bash
##
## DESCRIPTION:   Call GATK SomaticIndelDetector
##
## USAGE:         gatk.somaticindeldetector.sh 
##                                             normal.bam
##                                             tumor.bam
##                                             sample_name
##                                             ref.fa
##                                             out_prefix
##
## OUTPUT:        out_prefix.vcf
##                out_prefix.indels.txt
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

# Process input params
BAM_N=$1
BAM_T=$2
SAMPL=$3
REFER=$4
PREFX=$5

# Format output filenames
O_LOG=$PREFX.log

# Run tool
$JAVAJAR2G $GATK                                          \
  -T SomaticIndelDetector                                 \
  -R $REFER                                               \
  -I:normal $BAM_N                                        \
  -I:tumor  $BAM_T                                        \
  -o $PREFX.vcf                                           \
  -verbose $PREFX.indels.txt                              \
  &> $O_LOG

# Arguments for SomaticIndelDetector:
#  -o,--out <out>                                      File to write variants (indels) in VCF format
#  -metrics,--metrics_file <metrics_file>              File to print callability metrics output
#  -verbose,--verboseOutput <verboseOutput>            Verbose output file in text format
#  -bed,--bedOutput <bedOutput>                        Lightweight bed output file (only positions and events, no 
#                                                      stats/annotations)
#  -refseq,--refseq <refseq>                           Name of RefSeq transcript annotation file. If specified, indels 
#                                                      will be annotated with GENOMIC/UTR/INTRON/CODING and with the gene 
#                                                      name
#  -filter,--filter_expressions <filter_expressions>   One or more logical expressions. If any of the expressions is TRUE, 
#                                                      putative indel will be discarded and nothing will be printed into 
#                                                      the output (unless genotyping at the specific position is 
#                                                      explicitly requested, see -genotype). Default: T_COV<6||N_COV<4||
#                                                      T_INDEL_F<0.3||T_INDEL_CF<0.7
#  -ws,--window_size <window_size>                     Size (bp) of the sliding window used for accumulating the coverage. 
#                                                      May need to be increased to accomodate longer reads or longer 
#                                                      deletions. A read can be fit into the window if its length on the 
#                                                      reference (i.e. read length + length of deletion gap(s) if any) is 
#                                                      smaller than the window size. Reads that do not fit will be 
#                                                      ignored, so long deletions can not be called if window is too small
#  -mnr,--maxNumberOfReads <maxNumberOfReads>          Maximum number of reads to cache in the window; if number of reads 
#                                                      exceeds this number, the window will be skipped and no calls will 
#                                                      be made from it

