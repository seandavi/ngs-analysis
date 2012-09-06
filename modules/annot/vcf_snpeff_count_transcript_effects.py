#!/usr/bin/env python
description = '''
Read in vcf file(s) outputted by SNPEff.
Count transcript effects.
Output results in pickle (.pkl) format
Outputs:
gene transcription effects counts
list of effects2impact mapping
gene to selected transcripts
'''

import argparse
import pickle
#from ngs import util
from ngs import vcf

def generate_counts(vcf_filenames,
                    t2l,
                    outprefix,
                    highest_priority=False):
    '''
    Read through a vcf file outputted by snpeff and count the transcription effects for each variant.
    If highest_priority is set to true, then only count the highest priority transcript effect
    per variant.
    '''
    # Generate SnpEffVcfFiles objects
    vcffiles = vcf.SnpEffVcfFiles([vcf.SnpEffVcfFile(fn) for fn in vcf_filenames])
    
    # Count up all the transcript effects
    g2t2e2c, effects2impact = vcffiles.count_transcript_effects_all(highest_priority=highest_priority)

    # Generate selected transcripts for each gene
    g2t = vcffiles.select_transcript_for_gene(g2t2e2c, effects2impact, t2l)
    
    # Create output files
    g2t2e2c_outfile = outprefix + '.counts.pkl'
    effects2impact_outfile = outprefix + '.eff2imp.pkl'
    g2t_outfile = outprefix + '.g2t.pkl'

    # Output to files
    with open(g2t2e2c_outfile, 'wb') as f:
        pickle.dump(g2t2e2c, f, pickle.HIGHEST_PROTOCOL)

    with open(effects2impact_outfile, 'wb') as f:
        pickle.dump(effects2impact, f, pickle.HIGHEST_PROTOCOL)

    with open(g2t_outfile, 'wb') as f:
        pickle.dump(g2t, f, pickle.HIGHEST_PROTOCOL)

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_files',
                    help='Vcf files outputted by SNPEff',
                    nargs='+',
                    type=str)
    ap.add_argument('-l', '--transcripts2length',
                    help='Pickle (.pkl) file containing the lengths of transcripts',
                    type=str,
                    required=True)
    ap.add_argument('-e', '--highest-priority-effect',
                    help='If this flag is set, the highest-priority effect transcript will be selected from each variant annotation',
                    action='store_true')
    ap.add_argument('-o', '--outprefix',
                    help='Output prefix',
                    default='transcript_effects')
    params = ap.parse_args()

    # Load transcripts2length file
    with open(params.transcripts2length, 'rb') as f:
        t2l = pickle.load(f)

    # Generate counts
    generate_counts(params.vcf_files,
                    t2l,
                    params.outprefix,
                    highest_priority=params.highest_priority_effect)


if __name__ == '__main__':
    main()
