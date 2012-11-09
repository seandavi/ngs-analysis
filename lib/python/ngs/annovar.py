#!/usr/bin/env python

import csv
from collections import defaultdict
#import pandas
#import pandas.rpy.common as com

class AnnovarCsv(object):
    '''
    Class to handle Annovar output excel csv files
    '''
#     def __init__(self, filename=None):
#         self.colnames = None
#         self.data = None
#         self.fname = filename
#         if self.fname is not None:
#             self.load_data(self.fname)

#     def load_data(self, fname):
#         '''
#         Load data
#         '''
#         with open(fname, 'r') as f:
#             reader = csv.reader(f, dialect='excel')

#             # Read and store the first row of column names
#             header_row = reader.next()

#             # Find index of 'Otherinfo'
#             last_colnum = header_row.index('Otherinfo') + 1
#             self.colnames = header_row[:last_colnum]

#             # Load data
#             self.data = pandas.DataFrame([tuple(row[:last_colnum]) for row in reader],
#                                          columns=self.colnames)
    def __init__(self, filehandle):
        self.filters = []
        self.reader = csv.reader(filehandle, dialect='excel')
        # Read in column headers
        self.header = self.reader.next()

    def __iter__(self):
        return self

    def next(self):
        #return dict(zip(self.header, self.reader.next()))
        return self.reader.next()

    def add_filter(self, filter):
        '''
        Add a filter
        '''
        self.filters.append(filter)

    def filtered_variants(self):
        '''
        Given a list of filters, generate resulting variants that pass all the filters
        '''
        for row in self:
            tests_passed = True
            for filter in self.filters:
                tests_passed = tests_passed and filter.pass_test(dict(zip(self.header, row)))
            if tests_passed:
                yield row

    def count(self, column_name):
        '''
        Given a list of filters, count up all the variants with respect to the values
        of a given column
        '''
        genecolindex = self.header.index('Gene')
        refcolindex = self.header.index(column_name)
        colval2varcounts = defaultdict(int)
        colval2genes = defaultdict(set)
        for row in self:
            colval = row[refcolindex]
            colval2varcounts[colval] += 1

            # Get gene name
            gene = row[genecolindex]
            colval2genes[colval].add(gene)
        return colval2varcounts, colval2genes

class AnnovarCsvFilter(object):
    '''
    Abstract filter class
    '''
    def pass_test(self):
        pass


class AnnovarCsvFilterFactory(object):
    '''
    Create filters for variants in annovar csv files
    '''
    def create_genes_selector(self,genes):
        '''
        Return a filter that tests to see if the variant occurs in a set of genes.
        Filter will pass the test if variant occurs in the gene set.
        '''
        class GeneSelector(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                return colname2val['Gene'] in genes
        return GeneSelector()

    def create_genes_filter(self, genes):
        '''
        Similar to create_genes_selector, but this time the filter will pass the test if variant
        does NOT occur within the gene set
        '''
        class GeneFilter(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                return colname2val['Gene'] not in genes
        return GeneFilter()

    def create_dbSNP_selector(self):
        '''
        Return a filter that tests to see if the variant occurs in dbSNP.
        Filter will pass the test if variant does occur in dbSNP
        '''
        class DbSNPSelector(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                return colname2val['dbSNP135'] and colname2val['dbSNP135'][:2] == 'rs'
        return DbSNPSelector()
        
    def create_dbSNP_filter(self):
        '''
        Return a filter that tests to see if the variant occurs in dbSNP.
        Filter will pass the test if variant does NOT occur in dbSNP
        '''
        class DbSNPFilter(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                return not colname2val['dbSNP135']
        return DbSNPFilter()

    def create_polyphen_pred_selector(self, prediction_set):
        '''
        Return a selector that tests to see if the polyphen prediction is in the
        prediction_set
        '''
        prediction_set = set(prediction_set)
        class PolyphenPredSelector(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                polyphenpred = colname2val['LJB_PolyPhen2_Pred']
                return polyphenpred == '' or polyphenpred in prediction_set
        return PolyphenPredSelector()

    def create_sift_pred_selector(self, prediction_set):
        '''
        Return a selector that tests to see if the sift prediction is in the prediction set
        '''
        prediction_set = set(prediction_set)
        class SIFTPredSelector(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                siftpred = colname2val['LJB_SIFT_Pred']
                return siftpred == '' or siftpred in prediction_set
        return SIFTPredSelector()

    def create_1000Genomes_maf_selector(self, equalval=None, minval=None, maxval=None):
        '''
        Return a filter that tests to see if the variant maf in 1000Genomes is either
        equal to equalval, or is > minval and < maxval
        '''
        if equalval is not None:
            _equalval = float(equalval)
        if minval is not None:
            _minval = float(minval)
        if maxval is not None:
            _maxval = float(maxval)
        class G1000Selector(AnnovarCsvFilter):
            def pass_test(self, colname2val):
                mafval = 0.0
                if colname2val['1000g2010nov_ALL']:
                    mafval = float(colname2val['1000g2010nov_ALL'])
                # Compare equal
                if equalval is not None:
                    return mafval == _equalval

                else:
                    # Compare against minimal accepted value
                    if minval is not None:
                        if mafval < _minval:
                            return False

                    # Compare against maximum accepted value
                    if maxval is not None:
                        if mafval > _maxval:
                            return False
                
                    return True
        return G1000Selector()
