#!/bin/bash
##
## DESCRIPTION:   Compare mutations against COSMIC and OMIM databases
##
## USAGE:         music.cosmic_omim.sh maf_file output_dir
##
## OUTPUT:        output_dir/cosmic_omim.tsv
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input parameters
MAFFILE=$1
OUT_DIR=$2

# Format output filenames
OUTPUTFILE=$OUT_DIR/cosmic_omim.tsv
OUTPUTLOG=$OUT_DIR.cosmic_omim.log

# Run tool
genome music cosmic-omim                  \
  --maf-file $MAFFILE                     \
  --output-file $OUTPUTFILE               \
  --reference-build Build37               \
  &> $OUTPUTLOG


# omimaa-dir
#   omim amino acid mutation database folder 
# cosmic-dir
#   cosmic amino acid mutation database folder 
#   Default value '/var/lib/genome/db/cosmic/56' if not specified
# verbose
#   Use this to display the larger working output 
# noverbose
#   Make verbose 'false' 
# wu-annotation-headers
#   Use this to default to wustl annotation format headers 
# nowu-annotation-headers
#   Make wu-annotation-headers 'false' 
# aa-range
#   Set how close a 'near' match is when searching for amino acid near hits 
#   Default value '2' if not specified
# nuc-range
#   Set how close a 'near' match is when searching for nucleotide position near hits 
#   Default value '5' if not specified
# show-known-hits
#   When a finding is novel, show known AA in that gene 
#   Default value 'true' if not specified
# noshow-known-hits
#   Make show-known-hits 'false' 
