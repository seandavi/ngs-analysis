#!/usr/bin/env python
description = '''
Read in multiple varscan vcf files annotated by SNPEff
Generate summaries about each variant by position, as well
as about each gene that contains the variants.
By default, when selecting which transcript to use for each variant,
select the transcript with the highest priority effect.
If all-transcripts flat is set, use all transcript for each variant.
If select-highest-transcript is set, select the transcript with the
highest number of mutations for the gene report.  Otherwise, will
exclude the transcripts and report only on the gene.
'''

import argparse
import re
import sys
from ngs import vcf

REPORT_POS_COLNAMES=['chrom',
                     'pos',
                     'ref',
                     'alt',
                     'normal_gt',
                     'tumor_gt',
                     'dbSNP',
                     'impact',
                     'effect',
                     'func_class',
                     'codon_change',
                     'aa_change',
                     'gene_biotype',
                     'coding',
                     'gene',
                     'transcript',
                     'exon',
                     'num_samples',
                     'samples']

def load_dbsnp(dbsnp_file):
    '''
    Generate a mapping from variant to rsid from a dbsnp13x.txt file
    '''
    # Load dbsnp info
    variant2rsid = {}
    f = open(dbsnp_file, 'r')
    for line in f:
        la = line.strip().split('\t')
        chrom = la[1].replace('chr','')
        pos = la[3]
        rsid = la[4]
        ref = la[7]
        observed = la[9].split('/')
        if ref == observed[0]:
            alt = observed[1]
        else:
            alt = observed[0]
        variant2rsid[':'.join([chrom, pos, ref, alt])] = rsid
    f.close()
    return variant2rsid

def load_vcflist(fin):
    '''
    Given a file input handle to a file in the format:
    Sample, Vcf file
    Load the data and return a list of tuples for each row
    '''
    sample_vcf = []
    for line in fin:
        la = line.strip().split('\t')
        sample = la[0]
        vcf_file = la[1]
        sample_vcf.append((sample,vcf_file))
    return sample_vcf

def variant_ext2variant(ve):
    '''
    Given a variant_ext in the format chrom:pos:ref:alt:normal_gt:tumor_gt
    return chrom:pos:ref:alt
    '''
    return ':'.join(ve.split(':')[:4])

def report_pos(sample_vcf, variant2rsid, outfilename, all_transcripts):
    '''
    Generate variant report, each row a variant position
    '''
    variant_ext2annots = {}
    variant_ext2samples = {}
    for s_v in sample_vcf:
        sampleid = s_v[0]
        vcffile = s_v[1]
        sys.stderr.write('\tProcessing sample %s, vcf file %s\n' % (sampleid,vcffile))
        report_pos_count_samples(sampleid,
                                 vcffile,
                                 variant_ext2annots,
                                 variant_ext2samples,
                                 all_transcripts)

    # Output results to file
    f = open(outfilename, 'w')
    # Output report header
    f.write('%s\n' % '\t'.join(REPORT_POS_COLNAMES))
    for variant_ext in variant_ext2samples:

        # Get rsid for the variant
        variant = variant_ext2variant(variant_ext)
        rsid = ''
        if variant in variant2rsid:
            rsid = variant2rsid[variant]

        # Output records for each annotation for each variant_ext
        for annot in variant_ext2annots[variant_ext]:
            f.write('%s\n' % '\t'.join([variant_ext.replace(':','\t'),
                                        rsid,
                                        annot,
                                        str(len(variant_ext2samples[variant_ext])),
                                        ','.join(sorted(variant_ext2samples[variant_ext]))]))
    f.close()

def report_pos_count_samples(sampleid,
                             vcfin,
                             variant_ext2annots,
                             variant_ext2samples,
                             all_transcripts):
    '''
    Read through vcf file, and update counts for variant_ext
    '''

    with vcf.SnpEffVcfFile(vcfin, 'r') as vcffile:

        # Skip to the variants section of the vcf file
        vcffile.jump2variants()
        
        # Read in the variant lines
        for line in vcffile:
            
            # Get parsed variant data
            variant = vcffile.parse_line(line)

            # Parse the info column
            info_map, info_single = vcffile.parse_info(variant)

            # Record columns
            chrom = variant['CHROM'].replace('chr','')
            pos = variant['POS']
            variantid = variant['ID']
            ref = variant['REF']
            alt = variant['ALT']

            # Parse effects
            if all_transcripts:
                effects = vcffile.parse_effects(variant)
            # Select single highest priority effect
            else:
                effects = [vcffile.select_highest_priority_effect(variant)]
                if effects[0] is None:
                    continue
            
            # Generate key, variant_ext
            normal_gt = vcffile.get_sample_gt(variant, 'NORMAL')
            tumor_gt = vcffile.get_sample_gt(variant, 'TUMOR')
            variant_ext = ':'.join([chrom, pos, ref, alt, normal_gt, tumor_gt])

            # Update counts
            if variant_ext not in variant_ext2annots:
                variant_ext2annots[variant_ext] = set()
            for effect in effects:
                variant_ext2annots[variant_ext].add('\t'.join([effect.impact,
                                                               effect.effect,
                                                               effect.functional_class,
                                                               effect.codon_change,
                                                               effect.aa_change,
                                                               effect.gene_biotype,
                                                               effect.coding,
                                                               effect.gene,
                                                               effect.transcript,
                                                               effect.exon]))
            if variant_ext not in variant_ext2samples:
                variant_ext2samples[variant_ext] = set()
            variant_ext2samples[variant_ext].add(sampleid)

def increment_count(mapping, key, val):
    if key not in mapping:
        mapping[key] = 0
    mapping[key] += val

def get_dict_count(mapping, k):
    '''
    Given a dictionary and its key, return the value
    If key is not in dictionary, return 0
    '''
    if k in mapping:
        return mapping[k]
    else:
        return 0

def get_num_nonsilent(t, transcript2missense, transcript2nonsense, transcript2splice_acceptor, transcript2splice_donor):
    return sum([get_dict_count(transcript2missense,t),
                get_dict_count(transcript2nonsense,t),
                get_dict_count(transcript2splice_acceptor,t),
                get_dict_count(transcript2splice_donor,t)])

def find_maximum_nonsilent_transcript(transcripts, transcript2missense, transcript2nonsense, transcript2splice_acceptor, transcript2splice_donor):
    '''
    Given a list of transcripts, find the transcript with the most
    nonsilent mutations
    '''
    transcripts = list(transcripts)
    mt = transcripts[0]
    for t in transcripts:
        mt_score = get_num_nonsilent(mt,
                                     transcript2missense,
                                     transcript2nonsense,
                                     transcript2splice_acceptor,
                                     transcript2splice_donor)
        t_score = get_num_nonsilent(t,
                                    transcript2missense,
                                    transcript2nonsense,
                                    transcript2splice_acceptor,
                                    transcript2splice_donor)
        if mt_score < t_score:
            mt = t
    return mt, t_score

def find_maximum_mutated_transcript(transcripts, transcript2totalmut):
    '''
    Given a list of transcripts, find the transcript with the most
    mutations
    '''
    transcripts = list(transcripts)
    mt = transcripts[0]
    for t in transcripts:
        mt_score = transcript2totalmut[mt]
        t_score = transcript2totalmut[t]
        if mt_score < t_score:
            mt = t
    return mt, t_score

def report_gene(report_pos_filename, report_gene_filename, most_mutated_transcript=False):
    '''
    Read in the report_pos file and generate a report on the variants where each row
    represents a gene
    '''
    if most_mutated_transcript:
        report_gene_highest(report_pos_filename, report_gene_filename)
        return

    gene2missense = {}
    gene2missense_stop_lost = {}
    gene2missense_start_lost = {}
    gene2missense_nonsyn_coding = {}
    gene2missense_nonsyn_start = {}
    gene2nonsense = {}
    gene2splice_acceptor = {}
    gene2splice_donor = {}
    gene2silent = {}
    gene2silent_syn_coding = {}
    gene2silent_syn_stop = {}
    gene2silent_start_lost = {}
    gene2totalmut = {}
    gene2samples = {}
    gene2samplepos = {}
    # Low effects
    gene2downstream = {}
    gene2exon = {}
    gene2intergenic = {}
    gene2intragenic = {}
    gene2intron = {}
    gene2start_gained = {}
    gene2upstream = {}
    gene2utr_3_prime = {}
    gene2utr_5_prime = {}

    with open(report_pos_filename, 'r') as f:
        for line in f:
            la = line.strip().split('\t')
            chrom = la[0]
            pos = la[1]
            impact = la[7]
            effect = la[8]
            func_class = la[9]
            gene = la[14]
            transcript = la[15]
            samples = la[-1].split(',')
            num_samples = len(samples)

            if not gene and not transcript:
                continue
            if gene and not transcript:
                transcript = gene
            if not gene and transcript:
                gene = transcript

            added = False
            if func_class == 'MISSENSE':
                added = True
                increment_count(gene2missense, gene, num_samples)
                if effect == 'STOP_LOST':
                    increment_count(gene2missense_stop_lost, gene, num_samples)
                elif effect == 'START_LOST':
                    increment_count(gene2missense_start_lost, gene, num_samples)
                elif effect == 'NON_SYNONYMOUS_CODING':
                    increment_count(gene2missense_nonsyn_coding, gene, num_samples)
                elif effect == 'NON_SYNONYMOUS_START':
                    increment_count(gene2missense_nonsyn_start, gene, num_samples)
            elif func_class == 'NONSENSE':
                added = True
                increment_count(gene2nonsense, gene, num_samples)
            elif effect == 'SPLICE_SITE_ACCEPTOR':
                added = True
                increment_count(gene2splice_acceptor, gene, num_samples)
            elif effect == 'SPLICE_SITE_DONOR':
                added = True
                increment_count(gene2splice_donor, gene, num_samples)
            elif func_class == 'SILENT':
                added = True
                increment_count(gene2silent, gene, num_samples)
                if effect == 'SYNONYMOUS_CODING':
                    increment_count(gene2silent_syn_coding, gene, num_samples)
                elif effect == 'SYNONYMOUS_STOP':
                    increment_count(gene2silent_syn_stop, gene, num_samples)
                elif effect == 'START_LOST':
                    increment_count(gene2silent_start_lost, gene, num_samples)
            elif effect == 'DOWNSTREAM':
                added = True
                increment_count(gene2downstream, gene, num_samples)
            elif effect == 'EXON':
                added = True
                increment_count(gene2exon, gene, num_samples)
            elif effect == 'INTERGENIC':
                added = True
                increment_count(gene2intergenic, gene, num_samples)
            elif effect == 'INTRAGENIC':
                added = True
                increment_count(gene2intragenic, gene, num_samples)
            elif effect == 'INTRON':
                added = True
                increment_count(gene2intron, gene, num_samples)
            elif effect == 'START_GAINED':
                added = True
                increment_count(gene2start_gained, gene, num_samples)
            elif effect == 'UPSTREAM':
                added = True
                increment_count(gene2upstream, gene, num_samples)
            elif effect == 'UTR_3_PRIME':
                added = True
                increment_count(gene2utr_3_prime, gene, num_samples)
            elif effect == 'UTR_5_PRIME':
                added = True
                increment_count(gene2utr_5_prime, gene, num_samples)

            if added:
                # Maintain total mutations added
                increment_count(gene2totalmut, gene, num_samples)

                # Maintain track of samples added for gene
                if gene not in gene2samples:
                    gene2samples[gene] = set()
                gene2samples[gene] = gene2samples[gene].union(set(samples))

                # Maintain track of sample_coords added for this gene
                if gene not in gene2samplepos:
                    gene2samplepos[gene] = set()
                for s in samples:
                    samplepos = ':'.join([s, chrom, pos])
                    gene2samplepos[gene].add(samplepos)

    # Output to file
    with open(report_gene_filename, 'w') as f:
        f.write('%s\n' % '\t'.join(['gene',
                                    'missense',
                                    'stop_lost',
                                    'start_lost',
                                    'nonsyn_coding',
                                    'nonsyn_start',
                                    'nonsense',
                                    'splice_acceptor',
                                    'splice_donor',
                                    'silent',
                                    'syn_coding',
                                    'syn_stop',
                                    'start_lost',
                                    'downstream',
                                    'exon',
                                    'intergenic',
                                    'intragenic',
                                    'intron',
                                    'start_gained',
                                    'upstream',
                                    'utr_3_prime',
                                    'utr_5_prime',
                                    'total',
                                    'num_samples',
                                    'sample:chr:pos']))
        for g in gene2samples:
            f.write('%s\n' % '\t'.join([g,
                                        str(get_dict_count(gene2missense, g)),
                                        str(get_dict_count(gene2missense_stop_lost, g)),
                                        str(get_dict_count(gene2missense_start_lost, g)),
                                        str(get_dict_count(gene2missense_nonsyn_coding, g)),
                                        str(get_dict_count(gene2missense_nonsyn_start, g)),
                                        str(get_dict_count(gene2nonsense, g)),
                                        str(get_dict_count(gene2splice_acceptor, g)),
                                        str(get_dict_count(gene2splice_donor, g)),
                                        str(get_dict_count(gene2silent, g)),
                                        str(get_dict_count(gene2silent_syn_coding, g)),
                                        str(get_dict_count(gene2silent_syn_stop, g)),
                                        str(get_dict_count(gene2silent_start_lost, g)),
                                        str(get_dict_count(gene2downstream, g)),
                                        str(get_dict_count(gene2exon, g)),
                                        str(get_dict_count(gene2intergenic, g)),
                                        str(get_dict_count(gene2intragenic, g)),
                                        str(get_dict_count(gene2intron, g)),
                                        str(get_dict_count(gene2start_gained, g)),
                                        str(get_dict_count(gene2upstream, g)),
                                        str(get_dict_count(gene2utr_3_prime, g)),
                                        str(get_dict_count(gene2utr_5_prime, g)),
                                        str(get_dict_count(gene2totalmut, g)),
                                        str(len(gene2samples[g])),
                                        ','.join(sorted(gene2samplepos[g]))]))
            
def report_gene_highest(report_pos_filename, report_gene_filename):
    '''
    Generate gene report with each gene represented by its most mutated transcript
    '''
    # Counters
    gene2transcript = {}
    transcript2missense = {}
    transcript2missense_stop_lost = {}
    transcript2missense_start_lost = {}
    transcript2missense_nonsyn_coding = {}
    transcript2missense_nonsyn_start = {}
    transcript2nonsense = {}
    transcript2splice_acceptor = {}
    transcript2splice_donor = {}
    transcript2silent = {}
    transcript2silent_syn_coding = {}
    transcript2silent_syn_stop = {}
    transcript2silent_start_lost = {}
    transcript2totalmut = {}
    transcript2samples = {}
    transcript2samplepos = {}
    # Low effects
    transcript2downstream = {}
    transcript2exon = {}
    transcript2intergenic = {}
    transcript2intragenic = {}
    transcript2intron = {}
    transcript2start_gained = {}
    transcript2upstream = {}
    transcript2utr_3_prime = {}
    transcript2utr_5_prime = {}

    f = open(report_pos_filename, 'r')
    for line in f:
        la = line.strip().split('\t')
        chrom = la[0]
        pos = la[1]
        impact = la[7]
        effect = la[8]
        func_class = la[9]
        gene = la[14]
        transcript = la[15]
        samples = la[-1].split(',')
        num_samples = len(samples)

        if not gene and not transcript:
            continue
        if gene and not transcript:
            transcript = gene
        if not gene and transcript:
            gene = transcript

        added = False
        if func_class == 'MISSENSE':
            added = True
            increment_count(transcript2missense, transcript, num_samples)
            if effect == 'STOP_LOST':
                increment_count(transcript2missense_stop_lost, transcript, num_samples)
            elif effect == 'START_LOST':
                increment_count(transcript2missense_start_lost, transcript, num_samples)
            elif effect == 'NON_SYNONYMOUS_CODING':
                increment_count(transcript2missense_nonsyn_coding, transcript, num_samples)
            elif effect == 'NON_SYNONYMOUS_START':
                increment_count(transcript2missense_nonsyn_start, transcript, num_samples)
        elif func_class == 'NONSENSE':
            added = True
            increment_count(transcript2nonsense, transcript, num_samples)
        elif effect == 'SPLICE_SITE_ACCEPTOR':
            added = True
            increment_count(transcript2splice_acceptor, transcript, num_samples)
        elif effect == 'SPLICE_SITE_DONOR':
            added = True
            increment_count(transcript2splice_donor, transcript, num_samples)
        elif func_class == 'SILENT':
            added = True
            increment_count(transcript2silent, transcript, num_samples)
            if effect == 'SYNONYMOUS_CODING':
                increment_count(transcript2silent_syn_coding, transcript, num_samples)
            elif effect == 'SYNONYMOUS_STOP':
                increment_count(transcript2silent_syn_stop, transcript, num_samples)
            elif effect == 'START_LOST':
                increment_count(transcript2silent_start_lost, transcript, num_samples)
        elif effect == 'DOWNSTREAM':
            added = True
            increment_count(transcript2downstream, transcript, num_samples)
        elif effect == 'EXON':
            added = True
            increment_count(transcript2exon, transcript, num_samples)
        elif effect == 'INTERGENIC':
            added = True
            increment_count(transcript2intergenic, transcript, num_samples)
        elif effect == 'INTRAGENIC':
            added = True
            increment_count(transcript2intragenic, transcript, num_samples)
        elif effect == 'INTRON':
            added = True
            increment_count(transcript2intron, transcript, num_samples)
        elif effect == 'START_GAINED':
            added = True
            increment_count(transcript2start_gained, transcript, num_samples)
        elif effect == 'UPSTREAM':
            added = True
            increment_count(transcript2upstream, transcript, num_samples)
        elif effect == 'UTR_3_PRIME':
            added = True
            increment_count(transcript2utr_3_prime, transcript, num_samples)
        elif effect == 'UTR_5_PRIME':
            added = True
            increment_count(transcript2utr_5_prime, transcript, num_samples)

        if added:
            # Get gene to transcript mapping
            if gene not in gene2transcript:
                gene2transcript[gene] = set()
            gene2transcript[gene].add(transcript)

            # Maintain total mutations added
            increment_count(transcript2totalmut, transcript, num_samples)

            # Maintain track of samples added for transcript
            if transcript not in transcript2samples:
                transcript2samples[transcript] = set()
            transcript2samples[transcript] = transcript2samples[transcript].union(set(samples))

            # Maintain track of sample_coords added for this transcript
            if transcript not in transcript2samplepos:
                transcript2samplepos[transcript] = set()
            for s in samples:
                samplepos = ':'.join([s, chrom, pos])
                transcript2samplepos[transcript].add(samplepos)
    f.close()

    # Output to file
    f = open(report_gene_filename,'w')
    f.write('%s\n' % '\t'.join(['gene',
                                'transcript',
                                'missense',
                                'stop_lost',
                                'start_lost',
                                'nonsyn_coding',
                                'nonsyn_start',
                                'nonsense',
                                'splice_acceptor',
                                'splice_donor',
                                'silent',
                                'syn_coding',
                                'syn_stop',
                                'start_lost',
                                'downstream',
                                'exon',
                                'intergenic',
                                'intragenic',
                                'intron',
                                'start_gained',
                                'upstream',
                                'utr_3_prime',
                                'utr_5_prime',
                                'total',
                                'num_samples',
                                'sample:chr:pos']))

    for gene in gene2transcript:
        # Find maximum variant transcript for gene
        t, t_score = find_maximum_mutated_transcript(gene2transcript[gene], transcript2totalmut)
        f.write('%s\n' % '\t'.join([gene,
                                    t,
                                    str(get_dict_count(transcript2missense, t)),
                                    str(get_dict_count(transcript2missense_stop_lost, t)),
                                    str(get_dict_count(transcript2missense_start_lost, t)),
                                    str(get_dict_count(transcript2missense_nonsyn_coding, t)),
                                    str(get_dict_count(transcript2missense_nonsyn_start, t)),
                                    str(get_dict_count(transcript2nonsense, t)),
                                    str(get_dict_count(transcript2splice_acceptor, t)),
                                    str(get_dict_count(transcript2splice_donor, t)),
                                    str(get_dict_count(transcript2silent, t)),
                                    str(get_dict_count(transcript2silent_syn_coding, t)),
                                    str(get_dict_count(transcript2silent_syn_stop, t)),
                                    str(get_dict_count(transcript2silent_start_lost, t)),
                                    str(get_dict_count(transcript2downstream, t)),
                                    str(get_dict_count(transcript2exon, t)),
                                    str(get_dict_count(transcript2intergenic, t)),
                                    str(get_dict_count(transcript2intragenic, t)),
                                    str(get_dict_count(transcript2intron, t)),
                                    str(get_dict_count(transcript2start_gained, t)),
                                    str(get_dict_count(transcript2upstream, t)),
                                    str(get_dict_count(transcript2utr_3_prime, t)),
                                    str(get_dict_count(transcript2utr_5_prime, t)),
                                    str(get_dict_count(transcript2totalmut, t)),
                                    str(len(transcript2samples[t])),
                                    ','.join(sorted(transcript2samplepos[t]))]))
    f.close()

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_files_list',
                    help='Vcf files list in a two-column tsv format (sample_id, path_to_vcf_file)',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('dbsnp_file',
                    help='dbsnp13x.txt file',
                    type=str)
    ap.add_argument('-a', '--all-transcripts',
                    help='If this flag is set, instead of selecting the highest priority effect transcript for each variant, all transcripts will be counted',
                    action='store_true')
    ap.add_argument('-m', '--most-mutated-transcript',
                    help='If this flag is set, report the transcript id in the gene report.  For each gene, select the transcript with the highest mutation count',
                    action='store_true')
    ap.add_argument('-o','--out-prefix',
                    help='Output prefix for the report files',
                    type=str,
                    default='report')
    params = ap.parse_args()

    # Set up output filenames
    out_report_pos = params.out_prefix + '.pos'
    out_report_gene = params.out_prefix + '.gene'

    # Generate [(sample_x, sample_x.vcf),(sample_y, sample_y.vcf),...]
    sample_vcf = load_vcflist(params.vcf_files_list)

    # Load dbsnp file to memory
    sys.stderr.write('Loading dbsnp file...')
    variant2rsid = load_dbsnp(params.dbsnp_file)
    sys.stderr.write('Done\n')

    # Generate positional report
    sys.stderr.write('Generating pos report...\n')
    report_pos(sample_vcf, variant2rsid, out_report_pos, params.all_transcripts)
    sys.stderr.write('Done\n')

    # Generate gene report
    sys.stderr.write('Generating gene report...')
    report_gene(out_report_pos, out_report_gene, params.most_mutated_transcript)
    sys.stderr.write('Done\n')


if __name__ == '__main__':
    main()
