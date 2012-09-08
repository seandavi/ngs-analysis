#!/usr/bin/env python

#import re
import sys
import itertools
from collections import defaultdict

class MafFile(file):
    '''
    Extension of the python File class to handle maf formatted files
    '''
    
    # Column names described in header line
    COLNAMES = ['Hugo_Symbol',
                'Entrez_Gene_Id',
                'Center',
                'NCBI_Build',
                'Chromosome',
                'Start_position',
                'End_position',
                'Strand',
                'Variant_Classification',
                'Variant_Type',
                'Reference_Allele',
                'Tumor_Seq_Allele1',
                'Tumor_Seq_Allele2',
                'dbSNP_RS',
                'dbSNP_Val_Status',
                'Tumor_Sample_Barcode',
                'Matched_Norm_Sample_Barcode',
                'Match_Norm_Seq_Allele1',
                'Match_Norm_Seq_Allele2',
                'Tumor_Validation_Allele1',
                'Tumor_Validation_Allele2',
                'Match_Norm_Validation_Allele1',
                'Match_Norm_Validation_Allele2',
                'Verification_Status',
                'Validation_Status',
                'Mutation_Status',
                'Sequencing_Phase',
                'Sequence_Source',
                'Validation_Method',
                'Score',
                'BAM_File',
                'Sequencer']

    def parse_line(self, line):
        '''
        Parse a line and return a dictionary mapping column names
        to variant values
        '''
        return dict(zip(self.COLNAMES, line.strip('\n').split('\t')))

    def generate_pos_report(self, fout=sys.stdout, detailed=False):
        '''
        Generate a positional report
        "detailed" option selects whether to use detailed annotated option or not
        If set to False(default), tool will simply count the sample frequency per mutation position.
        Optional output to ostream fout
        Note: This file iterator must be positioned at the top of the file
        work properly.
        '''

        # Simple version
        poskey_columns = ('Chromosome',
                          'Start_position',
                          'End_position',
                          'Variant_Type')

        # Detailed version
        if detailed:
            poskey_columns = ('Hugo_Symbol',
                              'Entrez_Gene_Id',
                              'Chromosome',
                              'Start_position',
                              'End_position',
                              'Variant_Classification',
                              'Variant_Type',
                              'Reference_Allele',
                              'Tumor_Seq_Allele1',
                              'Tumor_Seq_Allele2',
                              'Match_Norm_Seq_Allele1',
                              'Match_Norm_Seq_Allele2')

        # Process file
        poskey2samples = defaultdict(set)
        for line in self:

            # Parse mutation data
            maf_record = self.parse_line(line)

            # Skip header line
            if maf_record['Hugo_Symbol'] == self.COLNAMES[0]:
                continue

            # Generate key
            poskey = tuple([maf_record[k] for k in poskey_columns])

            # Update sample list for the given mutation
            poskey2samples[poskey].add(maf_record['Tumor_Sample_Barcode'])
            
        # Sorted Output

        fout.write('%s\n' % '\t'.join(list(poskey_columns) + ['Num_Samples','Samples']))
        for poskey,samples in sorted(poskey2samples.items()):
            fout.write('%s\t%i\t%s\n' % ('\t'.join(poskey),
                                         len(samples),
                                         ','.join(sorted(samples))))
        return poskey2samples
                

    def generate_gene_report(self, fout=sys.stdout):
        '''
        Generate a gene report
        Optional output to ostream fout
        Note: This file iterator must be positioned at the top of the file
        '''

        g2c2varcounts = defaultdict(dict)
        g2c2samples = defaultdict(dict)
        g2c2samplepos = defaultdict(dict)
        var_classes = set()
        for line in self:
            # Parse mutation data
            maf_record = self.parse_line(line)

            # Skip header line
            if maf_record['Hugo_Symbol'] == self.COLNAMES[0]:
                continue

            # Update counts
            gene = maf_record['Hugo_Symbol']
            var_class = maf_record['Variant_Classification']
            var_classes.add(var_class)
            g2c2varcounts[gene][var_class] = g2c2varcounts[gene].setdefault(var_class, 0) + 1

            # Update samples
            sample = maf_record['Tumor_Sample_Barcode']
            g2c2samples[gene].setdefault(var_class, set()).add(sample)

            # Update samplepos
            chrom = maf_record['Chromosome'].replace('chr','')
            pos = maf_record['Start_position']
            samplepos = ':'.join([sample, chrom, pos])
            g2c2samplepos[gene].setdefault(var_class, set()).add(samplepos)
            
        # Output results
        # Format and output header line
        var_classes = sorted(var_classes)
        sample_cols = ['%s_Num_Samples\t%s_Sample_Chrom_Pos' % (vc,vc) for vc in var_classes]
        var_classes_columns = list(itertools.chain(*zip(var_classes,sample_cols)))
        fout.write('%s\n' % '\t'.join(['Gene'] +
                                      var_classes_columns +
                                      ['Total',
                                       'Total_Num_Samples',
                                       'Total_Sample_Chrom_Pos']))
        # Output counts per gene
        for g in g2c2varcounts:
            # Start with gene name
            output_line_items = [g]

            # Append var class info
            total = 0
            total_samples = set()
            total_samplepos = set()
            for vc in var_classes:
                varcounts = g2c2varcounts[g].setdefault(vc,0)
                samples = g2c2samples[g].setdefault(vc,set())
                samplepos = g2c2samplepos[g].setdefault(vc,set())
                output_line_items.append(str(varcounts))
                output_line_items.append(str(len(samples)))
                output_line_items.append(','.join(sorted(samplepos)))

                # Update total counts
                total += varcounts
                total_samples.update(samples)
                total_samplepos.update(samplepos)

            # Append total counts info
            output_line_items.append(str(total))
            output_line_items.append(str(len(total_samples)))
            output_line_items.append(','.join(sorted(total_samplepos)))

            # Output the line
            fout.write('%s\n' % '\t'.join(output_line_items))

        return g2c2varcounts, g2c2samples, g2c2samplepos
