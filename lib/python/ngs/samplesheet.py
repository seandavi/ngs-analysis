#!/usr/bin/env python

import re
import sys

class SampleSheet(object):
    '''
    Class to handle Illumina samplesheets
    '''
    COLUMN_HEADER = ['FCID',
                     'Lane',
                     'SampleID',
                     'SampleRef',
                     'Index',
                     'Description',
                     'Control',
                     'Recipe',
                     'Operator',
                     'SampleProject']
    ILLEGAL_CHARS = ['\s', '\?','\(','\)',
                     '\[','\]','\/','\\\\','=',
                     '\+','<','>',':',';',
                     '"','\\\'','\*','\^',
                     '\|','&','\.']

    def __init__(self, samplesheet):
        '''
        Constructor
        samplesheet is a string object containing samplesheet data
        '''
        self.samplesheet = samplesheet
        self.ss_matrix = self.to_matrix(self.samplesheet)

    def clip_extra_rows(self, matrix):
        '''
        If the samplesheet contains extra lines, clip them
        '''
        while matrix[-1] == ['']:
            matrix = matrix[:-1]
        return matrix

    def to_matrix(self, samplesheet):
        '''
        Convert a samplesheet string object into a 2-D list
        '''
        matrix = []
        for row in samplesheet.split('\n'):
            matrix.append(row.split(','))
        return self.clip_extra_rows(matrix)

    def check_num_columns(self):
        '''
        Number of columns for each row must be equal to the length of column header
        '''
        num_cols = len(self.COLUMN_HEADER)
        for row in self.ss_matrix:
            if len(row) != num_cols:
                return False
        return True
        
    def check_illegal_chars(self):
        '''
        Check to see if samplesheet contains illegal chars
        '''
        for row in self.ss_matrix:
            for item in row:
                for char in self.ILLEGAL_CHARS:
                    if re.search(char, item):
                        sys.stderr.write('Illegal character \'%s\' found in \'%s\'\n' % (char,item))
                        return False
        return True

#     def check_index_lens(self):
#         '''
#         Check to make sure that the index lengths are all equal
#         '''
#         index_lengths = set()
#         for row in self.ss_matrix[1:]:
#             collabel2val = dict(zip(self.COLUMN_HEADER, row))
#             index_lengths.add(len(collabel2val['Index']))
#         if len(index_lengths) > 1:
#             return False
#         return True
            
    def check_duplicate_index_per_lane(self):
        '''
        Check to see if the same index is given for the same lane
        '''
        laneindices = set()
        for row in self.ss_matrix[1:]:
            collabel2val = dict(zip(self.COLUMN_HEADER, row))
            lane = collabel2val['Lane']
            index = collabel2val['Index']
            laneindex = lane + ':' + index
            if laneindex in laneindices:
                sys.stderr.write('Multiple occurrences of index %s for lane %s\n' % (index, lane))
                return False
            laneindices.add(laneindex)
        return True

    def check_weird_chars(self):
        '''
        Check to make sure that only alphanumeric values are used
        '''
        for row in self.ss_matrix:
            for val in row:
                if re.match('^[\w-]+$', val) is None and val != '':
                    sys.stderr.write('Invalid characters used in \'%s\'\n' % val)
                    return False
        return True

    def check_sanity(self):
        '''
        Run sanity check on the samplesheet
        - Number of columns in each row must be the same
        - Cannot have spaces, forward or backward slashes (illegal chars)
        - Length of index sequences must all be the same
        - Cannot have same index for same lane
        - Character set - no weird symbols
        '''
        valid = True

        if not self.check_num_columns():
            sys.stderr.write('Invalid column count\n')
            valid = valid & False
        
        if not self.check_illegal_chars():
            sys.stderr.write('Invalid characters found\n')
            valid = valid & False

#         if not self.check_index_lens():
#             sys.stderr.write('Index lengths are not all equal\n')
#             valid = valid & False

        if not self.check_duplicate_index_per_lane():
            sys.stderr.write('Multiple occurrences of the same index in the same lane\n')
            valid = valid & False

        if not self.check_weird_chars():
            sys.stderr.write('Invalid characters used\n')
            valid = valid & False

        if valid:
            sys.stdout.write('Samplesheet is valid\n')

        return valid
