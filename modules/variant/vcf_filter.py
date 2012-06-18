#!/usr/bin/env python

description='''
Filter VCF files based on several criteria
Based on format version VCFv4.0

BUG:  Multiple sample thresholds will result in just the last filter being applied.  For now, use sample thresholds separately.
'''
import argparse
import sys

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

def build_genotype_field2indx(field_str):
    '''
    Generate a dictionary that maps the sample genotype field to their corresponding index
    '''
    fields = field_str.split(':')
    field2indx = {}
    for i,fieldname in enumerate(fields):
        field2indx[fieldname] = i
    return field2indx

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

def load_col_ids(col_id_file):
    '''
    Load a list of ids from file into a set
    '''
    id_set = set()
    try:
        f = open(col_id_file, 'r')
    except IOError:
        sys.stderr.write('File %s does not exist.\nExiting...\n\n' % col_id_file)
        sys.exit(1)
    for line in f:
        id_set.add(line.strip())
    f.close()
    return id_set

def boolean_or(left_operand, right_operand):
    return left_operand or right_operand

def boolean_and(left_operand, right_operand):
    return left_operand and right_operand

def generate_col_info_af_comparison_fnc(col_info_af_eq, col_info_af_gt, col_info_af_lt):
    '''
    Generate a comparison function based on the parameters, and return the function
    '''
    if col_info_af_gt is not None:
        # >=
        if col_info_af_eq is not None:
            return lambda x: x >= col_info_af_gt
        # >
        else:
            return lambda x: x > col_info_af_gt
    elif col_info_af_lt is not None:
        # <=
        if col_info_af_eq is not None:
            return lambda x: x <= col_info_af_lt
        # <
        else:
            return lambda x: x < col_info_af_lt
    # ==
    elif col_info_af_eq is not None:
        return lambda x: x == col_info_af_eq
    else:
        return lambda x: True

def filter_vcf_file(fin, 
                    col_filter=None,
                    col_info_af_eq=None,
                    col_info_af_gt=None,
                    col_info_af_lt=None,
                    col_id_file=None,
                    dbsnp=False,
                    denovo=False,
                    remove_indel=False,
                    sample_require_all=False,
                    sample_gq_threshold=None, 
                    sample_dp_threshold=None,
                    sample_dp_nocall=None):
    '''
    Read through the vcf file and filter based on conditions
    '''

    # Check to see if any INFO:AF thresholds are set
    col_info_af_thresholds_exist = False
    if (col_info_af_eq is not None) or (col_info_af_gt is not None) or (col_info_af_lt is not None):
        col_info_af_thresholds_exist = True
        col_info_af_comparison_fnc = generate_col_info_af_comparison_fnc(col_info_af_eq, col_info_af_gt, col_info_af_lt)

    # If col id file is provided, load the list of ids
    if col_id_file is not None:
        id_col_set = load_col_ids(col_id_file)

    # Check to see if any sample thresholds are set
    sample_thresholds_exist = False
    if ((sample_gq_threshold is not None) or 
        (sample_dp_threshold is not None) or
        (sample_dp_nocall is not None)):
        sample_thresholds_exist = True
        # Set the type of operator (and | or)
        if sample_require_all:
            sample_requirements_operator = boolean_and
            pass_sample_filter_init = True
        else:
            sample_requirements_operator = boolean_or
            pass_sample_filter_init = False

    # Read through the vcf file
    for line in fin:
        
        # Headers: print w/o filtering
        if line[0:2] == '##':
            sys.stdout.write(line)
            continue

        # Column Labels: print and build column-to-column_number mapping
        if line[0] == '#':
            colname2colnum, sample_names, sample_indexes = build_colname2colnum(line[1:].strip())
            sys.stdout.write(line)
            continue

        la = line.strip().split('\t')

        #----------------------------------------------
        # Filtering parameters

        # Column filtering ---------------------
        # FILTER column
        if col_filter is not None:
            col_val = la[colname2colnum['FILTER']]
            if col_val != col_filter:
                continue

        # INFO column - allele frequency (AF)
        if col_info_af_thresholds_exist:
            col_val = la[colname2colnum['INFO']]
            info_field2val = build_info_field2val(col_val)
            af = float(info_field2val['AF'])
            # If allele frequency does not pass the comparison function
            #   skip this variant
            if not col_info_af_comparison_fnc(af):
                continue

        # ID column - check to see if it's in a list
        if col_id_file is not None:
            col_val = la[colname2colnum['ID']]
            if col_val not in id_col_set:
                continue

        # ID column - check for dbsnp
        if dbsnp:
            col_val = la[colname2colnum['ID']]
            if len(col_val) < 3 or col_val[:2] != 'rs':
                continue

        # ID column - check for de novo
        if denovo:
            col_val = la[colname2colnum['ID']]
            if col_val != '.':
                continue

        # Remove indel
        if remove_indel:
            geno_ref = la[colname2colnum['REF']]
            geno_alts = la[colname2colnum['ALT']].split(',')
            alt_is_indel = False
            for geno_alt in geno_alts:
                if len(geno_alt) > 1 or geno_alt == '-':
                    alt_is_indel = True
                    break
            if len(geno_ref) > 1 or geno_ref == '-' or alt_is_indel:
                continue

        # If sample filtering thresholds are set
        if sample_thresholds_exist:
            # Sample value filtering ---------------
            pass_sample_filter = pass_sample_filter_init
            genotype_field2indx = build_genotype_field2indx(la[colname2colnum['FORMAT']])
            # Loop through the sample columns
            for sample_indx in sample_indexes:

                sample_genotype_info_str = la[sample_indx]
                sample_genotype_info = sample_genotype_info_str.split(':')

                # Check if 'no call'
                if sample_genotype_info_str == './.' or sample_genotype_info[genotype_field2indx['GT']] == './.':
                    pass_sample_filter = sample_requirements_operator(pass_sample_filter, False)
                    continue

                # SAMPLE GQ threshold
                if sample_gq_threshold is not None:
                    sample_gq = float(sample_genotype_info[genotype_field2indx['GQ']])
                    if sample_gq >= sample_gq_threshold:
                        pass_sample_filter = sample_requirements_operator(pass_sample_filter, True)
                    else:
                        pass_sample_filter = sample_requirements_operator(pass_sample_filter, False)

                # SAMPLE DP
                if sample_dp_threshold is not None:
                    sample_dp = int(sample_genotype_info[genotype_field2indx['DP']])
                    if sample_dp >= sample_dp_threshold:
                        pass_sample_filter = sample_requirements_operator(pass_sample_filter, True)
                    else:
                        pass_sample_filter = sample_requirements_operator(pass_sample_filter, False)

                # SAMPLE DP NOCALL THRESHOLD - IF SAMPLE DOESN'T MEET THRESHOLD, THEN CONVERT TO NC
                if sample_dp_nocall is not None:
                    sample_dp = int(sample_genotype_info[genotype_field2indx['DP']])
                    if sample_dp < sample_dp_nocall:
                        sample_genotype_info_str = './.'
                        la[sample_indx] = sample_genotype_info_str
                        line = '%s\n' % ('\t'.join(la))
                    pass_sample_filter = sample_requirements_operator(pass_sample_filter, True)

            # Check if sample filter requirements have been met
            if not pass_sample_filter:
                continue

        # Passed all requirements, write to output
        sys.stdout.write(line)

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('--col-filter',
                    help='Extract rows with the given FILTER column value (i.e. PASS, HARD_TO_VALIDATE)',
                    type=str,
                    default=None)
    ap.add_argument('--col-info-af-eq',
                    help='Extract rows with samples allele frequency == given value',
                    type=float,
                    default=None)
    ap.add_argument('--col-info-af-gt',
                    help='Extract rows with samples allele frequency > given value',
                    type=float,
                    default=None)
    ap.add_argument('--col-info-af-lt',
                    help='Extract rows with samples allele frequency < given value',
                    type=float,
                    default=None)
    ap.add_argument('--col-id-file',
                    help='Extract rows with the ID column value matching the ids listed in a file. Probably be used to filter by a list of rsids.',
                    type=str,
                    default=None)
    ap.add_argument('--dbsnp',
                    help='Extract dbsnp variants',
                    action='store_true')
    ap.add_argument('--denovo',
                    help='Extract de novo variants',
                    action='store_true')
    ap.add_argument('--remove-indel',
                    help='Remove variants that are indels',
                    action='store_true')
    ap.add_argument('--sample-gq-threshold',
                    help='Extract rows with sample genotype quality >= given value',
                    type=float,
                    default=None)
    ap.add_argument('--sample-dp-threshold',
                    help='Extract rows with sample depth >= given value',
                    type=int,
                    default=None)
    ap.add_argument('--sample-dp-nocall',
                    help='Convert sample calls to nocalls if depth < given value',
                    type=int,
                    default=None)
    ap.add_argument('--sample-require-all',
                    help='If true, all samples must meet the sample filtering requirements, as opposed to just a single one',
                    type=bool,
                    default=False)
    params = ap.parse_args()

    # Filter and write to standard output
    filter_vcf_file(params.vcf_file,
                    col_filter=params.col_filter,
                    col_info_af_eq=params.col_info_af_eq,
                    col_info_af_gt=params.col_info_af_gt,
                    col_info_af_lt=params.col_info_af_lt,
                    col_id_file=params.col_id_file,
                    dbsnp=params.dbsnp,
                    denovo=params.denovo,
                    remove_indel=params.remove_indel,
                    sample_require_all=params.sample_require_all,
                    sample_gq_threshold=params.sample_gq_threshold,
                    sample_dp_threshold=params.sample_dp_threshold,
                    sample_dp_nocall=params.sample_dp_nocall)
    params.vcf_file.close()


if __name__ == '__main__':
    main()
