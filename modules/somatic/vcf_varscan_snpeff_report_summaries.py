#!/usr/bin/env python
description = '''
Read in multiple varscan vcf files annotated by SNPEff
Generate summaries about each variant by position, as well
as about each gene that contains the variants.
When selecting which transcript to use for each variant,
select the transcript with the highest priority effect.
When reporting for each gene, select the transcript with the
most number of (interesting) variants.
'''

import argparse
import re
import sys

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

def get_effects_categories():
    effects_cats = [['High','SPLICE_SITE_ACCEPTOR'],
                    ['High','SPLICE_SITE_DONOR'],
                    ['High','START_LOST'],
                    ['High','EXON_DELETED'],
                    ['High','FRAME_SHIFT'],
                    ['High','STOP_GAINED'],
                    ['High','STOP_LOST'],
                    ['Moderate','NON_SYNONYMOUS_CODING'],
                    ['Moderate','CODON_CHANGE'],
                    ['Moderate','CODON_INSERTION'],
                    ['Moderate','CODON_CHANGE_PLUS_CODON_INSERTION'],
                    ['Moderate','CODON_DELETION'],
                    ['Moderate','CODON_CHANGE_PLUS_CODON_DELETION'],
                    ['Moderate','UTR_5_DELETED'],
                    ['Moderate','UTR_3_DELETED'],
                    ['Low','SYNONYMOUS_START'],
                    ['Low','NON_SYNONYMOUS_START'],
                    ['Low','START_GAINED'],
                    ['Low','SYNONYMOUS_CODING'],
                    ['Low','SYNONYMOUS_STOP'],
                    ['Low','NON_SYNONYMOUS_STOP'],
                    ['Modifier','UTR_5_PRIME'],
                    ['Modifier','UTR_3_PRIME'],
                    ['Modifier','REGULATION'],
                    ['Modifier','UPSTREAM'],
                    ['Modifier','DOWNSTREAM'],
                    ['Modifier','GENE'],
                    ['Modifier','TRANSCRIPT'],
                    ['Modifier','EXON'],
                    ['Modifier','INTRON_CONSERVED'],
                    ['Modifier','INTRON'],
                    ['Modifier','INTRAGENIC'],
                    ['Modifier','INTERGENIC'],
                    ['Modifier','INTERGENIC_CONSERVED'],
                    ['Modifier','NONE'],
                    ['Modifier','CHROMOSOME'],
                    ['Modifier','CUSTOM'],
                    ['Modifier','CDS']]
    effects2impact = {}
    effects = []
    for row in effects_cats:
        impact = row[0]
        effect = row[1]
        effects2impact[effect] = impact
        effects.append(effect)
    return effects, effects2impact

def build_sampleinfo_field2indx(field_str):
    '''
    Generate a dictionary that maps the sample genotype field to their corresponding index
    '''
    fields = field_str.split(':')
    field2indx = {}
    for i,fieldname in enumerate(fields):
        field2indx[fieldname] = i
    return field2indx

def build_colname2colnum(colname_str):
    '''
    Generate a dictionary that maps column name to the column index number
    Also generates a list of all the sample ids separately, which is a subset of the column names
    Also generates a sorted list of all the sample ids' indexes
    Assumes that sample ids are located to the right of the FORMAT column
    '''
    colnames = colname_str.split()
    colname2colnum = {}
    for i,colname in enumerate(colnames):
        colname2colnum[colname] = i

    # Sample ids
    first_sample_index = colname2colnum['FORMAT'] + 1
    sample_names = colnames[first_sample_index:]
    sample_indexes = sorted([colname2colnum[sn] for sn in sample_names])
    return colname2colnum, sample_names, sample_indexes

def build_info_field2val(field_str):
    '''
    Generate a dictionary that maps the info column fields to their corresponding values
    '''
    field_str_array = field_str.split(';')
    field2val = {}
    for p in field_str_array:
        pa = p.split('=')
        if len(pa) == 2:
            field2val[pa[0]] = pa[1]
    return field2val

def convert_allele2bases(allele_str, ref, alt):
    '''
    Given an allele string i.e. 0/0, 0/1, 1/1, convert to genotype string i.e. A/A, C/G
    '''
    alleles = allele_str.split('/')
    bases = []
    for a in alleles:
        if a == '0':
            bases.append(ref)
        elif a == '1':
            bases.append(alt)
        elif a == '.':
            bases.append('N')
        else:
            sys.stderr.write('Could not recognize allele %s\nExiting\n\n' % allele_str)
            sys.exit(1)
    return '/'.join(bases)

def parse_effect(info_str, effects):
    '''
    Parse the info column string in the vcf file, and extract the highest-priority effect, impact,
    and the corresponding gene name
    '''
    # Extract out the effects information string
    effect_info = re.search('EFF=(.*)', info_str).group(1)

    # Prioritize each effect information based on the effects list
    locus_effects = effect_info.split(',')
    locus_effects_priorities = []
    for le_string in locus_effects:
        locus_effect = re.search('(.+)\(', le_string).group(1)
        for i,e in enumerate(effects):
            if locus_effect == e:
                locus_effects_priorities.append(i)
                break

    # Extract out the effect, impact, and gene name
    highest_priority_num = min(locus_effects_priorities)
    for i,n in enumerate(locus_effects_priorities):
        if n == highest_priority_num:
            effect = re.search('(.+)\(', locus_effects[i]).group(1)
            effect_array = re.search('\((.+)\)', locus_effects[i]).group(1).split('|')
            effect_impact = effect_array[0]
            functional_class = effect_array[1]
            codon_change = effect_array[2]
            aa_change = effect_array[3]
            gene_name = effect_array[4]
            gene_biotype = effect_array[5]
            coding = effect_array[6]
            transcript = effect_array[7]
            exon = effect_array[8]
            return (effect, 
                    effect_impact,
                    functional_class,
                    codon_change,
                    aa_change,
                    gene_name,
                    gene_biotype,
                    coding,
                    transcript,
                    exon)

def parse_effect_all(info_str, effects):
    '''
    Parse the info column string in the vcf file, and extract all trancript effects, impact,
    and the corresponding gene name
    '''
    # Extract out the effects information string
    effect_info = re.search('EFF=(.*)', info_str).group(1)

    # Collect all effects tuples
    locus_effects = effect_info.split(',')
    all_transcript_effects = []
    for le_string in locus_effects:
        locus_effect = re.search('(.+)\(', le_string).group(1)
        effect_array = re.search('\((.+)\)', le_string).group(1).split('|')
        effect_impact = effect_array[0]
        functional_class = effect_array[1]
        codon_change = effect_array[2]
        aa_change = effect_array[3]
        gene_name = effect_array[4]
        gene_biotype = effect_array[5]
        coding = effect_array[6]
        transcript = effect_array[7]
        exon = effect_array[8]
        all_transcript_effects.append((locus_effect, 
                                       effect_impact,
                                       functional_class,
                                       codon_change,
                                       aa_change,
                                       gene_name,
                                       gene_biotype,
                                       coding,
                                       transcript,
                                       exon))
    return all_transcript_effects

def append_to_sample_names(sampleslist, append_str):
    '''
    Input a list of sample names, and postfix them with additional string
    '''
    return ['_'.join([sample, append_str]) for sample in sampleslist]

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

def report_pos(sample_vcf, effects, effects2impact, variant2rsid, outfilename, all_transcripts):
    '''
    Generate variant report, each row a variant position
    '''
    variant_ext2annots = {}
    variant_ext2samples = {}
    for s_v in sample_vcf:
        sampleid = s_v[0]
        vcffile = s_v[1]
        sys.stderr.write('\tProcessing sample %s, vcf file %s\n' % (sampleid,vcffile))
        f = open(vcffile, 'r')
        report_pos_count_samples(sampleid, f, effects, effects2impact, variant_ext2annots, variant_ext2samples, all_transcripts)
        f.close()

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

def report_pos_count_samples(sampleid, fin, effects, effects2impact, variant_ext2annots, variant_ext2samples, all_transcripts):
    '''
    Read through vcf file, and update counts for variant_ext
    '''

    for line in fin:
        # Headers
        if line[0:2] == '##':
            continue

        # Column Labels: build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())
            continue
        
        # Parse each row of data
        la = line.strip().split()

        # Build info column field2val mapping
        info_field2val = build_info_field2val(la[colname2colnum['INFO']])

        # Record columns
        chrom = la[colname2colnum['CHROM']].replace('chr','')
        pos = la[colname2colnum['POS']]
        variantid = la[colname2colnum['ID']]
        ref = la[colname2colnum['REF']]
        alt = la[colname2colnum['ALT']]
        qual = la[colname2colnum['QUAL']]
        filtr = la[colname2colnum['FILTER']]
        #total_dp = info_field2val['DP']
        
        # Parse effects
        if all_transcripts: # Report all transcript effects per variant
            parse_effect_results = parse_effect_all(la[colname2colnum['INFO']], effects)
        else: # Select highest priority effect transcript
            parse_effect_results = [parse_effect(la[colname2colnum['INFO']], effects)]
            # (effect, 
            #  effect_impact,
            #  functional_class,
            #  codon_change,
            #  aa_change,
            #  gene_name,
            #  gene_biotype,
            #  coding,
            #  transcript,
            #  exon) = parse_effect(la[colname2colnum['INFO']], effects)
        
        # Build sample info string format mapping
        format_string = la[colname2colnum['FORMAT']]
        sample_field2indx = build_sampleinfo_field2indx(format_string)
        sample2gt = {}
        for sample_name in sample_names:
            sample_i = colname2colnum[sample_name]
            sample_info_str = la[sample_i]

            # Check if 'no call'
            if sample_info_str == './.':
                sample_info_str = './.::::'

            sample_info_list = sample_info_str.split(':')
            sample_gt = sample_info_list[sample_field2indx['GT']]
            sample2gt[sample_name] = convert_allele2bases(sample_gt, ref, alt)

        # Generate key, variant_ext
        normal_gt = sample2gt['NORMAL']
        tumor_gt = sample2gt['TUMOR']
        variant_ext = ':'.join([chrom, pos, ref, alt, normal_gt, tumor_gt])

        # Update counts
        if variant_ext not in variant_ext2annots:
            variant_ext2annots[variant_ext] = set()
        for per in parse_effect_results:
            effect_impact = per[1]
            effect = per[0]
            functional_class = per[2]
            codon_change = per[3]
            aa_change = per[4]
            gene_biotype = per[6]
            coding = per[7]
            gene_name = per[5]
            transcript = per[8]
            exon = per[9]
            variant_ext2annots[variant_ext].add('\t'.join([effect_impact,
                                                           effect,
                                                           functional_class,
                                                           codon_change,
                                                           aa_change,
                                                           gene_biotype,
                                                           coding,
                                                           gene_name,
                                                           transcript,
                                                           exon]))
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
        mt_score = get_num_nonsilent(mt, transcript2missense, transcript2nonsense, transcript2splice_acceptor, transcript2splice_donor)
        t_score = get_num_nonsilent(t, transcript2missense, transcript2nonsense, transcript2splice_acceptor, transcript2splice_donor)
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

def report_gene(report_pos_filename, report_gene_filename):
    '''
    Read in the report_pos file and generate a report on the variants
    where each row represents a gene name
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
    ap.add_argument('--all-transcripts',
                    help='If this flag is set, instead of selecting the highest priority effect transcript for each variant, all transcripts will be counted',
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

    # Load effects
    effects, effects2impact = get_effects_categories()

    # Load dbsnp file to memory
    sys.stderr.write('Loading dbsnp file...')
    variant2rsid = load_dbsnp(params.dbsnp_file)
    sys.stderr.write('Done\n')

    # Generate positional report
    sys.stderr.write('Generating pos report...\n')
    report_pos(sample_vcf, effects, effects2impact, variant2rsid, out_report_pos, params.all_transcripts)
    sys.stderr.write('Done\n')

    # Generate gene report
    sys.stderr.write('Generating gene report...')
    report_gene(out_report_pos, out_report_gene)
    sys.stderr.write('Done\n')


if __name__ == '__main__':
    main()
