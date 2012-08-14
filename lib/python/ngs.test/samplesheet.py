#!/usr/bin/env python

import os
import unittest
from ngs import samplesheet

RESOURCE_DIR = 'resources'
SAMPLESHEET_NORM = 'samplesheet.normal.csv'
SAMPLESHEET_BAD = 'samplesheet.bad.csv'

class TestSampleSheet(unittest.TestCase):
    
    def setUp(self):
        # Load normal samplesheet
        samplesheet_norm_file = os.path.join(RESOURCE_DIR, SAMPLESHEET_NORM)
        f = open(samplesheet_norm_file,'r')
        ss_data_norm = f.read()
        f.close()
        self.samplesheet_norm = samplesheet.SampleSheet(ss_data_norm)

        # Load bad samplesheet
        samplesheet_bad_file = os.path.join(RESOURCE_DIR, SAMPLESHEET_BAD)
        f = open(samplesheet_bad_file, 'r')
        ss_data_bad = f.read()
        f.close()
        self.samplesheet_bad = samplesheet.SampleSheet(ss_data_bad)

    def test_to_matrix(self):
        s = 'a1,b1,c1\na2,b2,c2\na3,b3,c3'
        m = self.samplesheet_norm.to_matrix(s)
        self.assertEqual('a1', m[0][0])
        self.assertEqual('b1', m[0][1])
        self.assertEqual('c1', m[0][2])
        self.assertEqual('a2', m[1][0])
        self.assertEqual('b2', m[1][1])
        self.assertEqual('c2', m[1][2])
        self.assertEqual('a3', m[2][0])
        self.assertEqual('b3', m[2][1])
        self.assertEqual('c3', m[2][2])
        self.assertEqual(3, len(m))
        self.assertEqual(3, len(m[0]))
        self.assertEqual(3, len(m[1]))
        self.assertEqual(3, len(m[2]))

        s = 'a1,b1,c1\na2,b2,c2\na3,b3,c3\n\n'
        m2 = self.samplesheet_norm.to_matrix(s)
        self.assertEqual(len(m),len(m2))
        self.assertEqual(len(m[1]),len(m2[1]))
        self.assertEqual(m[0][2], m2[0][2])
        self.assertEqual(m[1][0], m2[1][0])
        self.assertEqual(m[2][1], m2[2][1])

    def test_check_num_columns(self):
        # Test column numbers
        self.assertTrue(self.samplesheet_norm.check_num_columns())
        self.assertFalse(self.samplesheet_bad.check_num_columns())

    def test_illegal_chars(self):
        self.assertTrue(self.samplesheet_norm.check_illegal_chars())
        bad_spaces = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1 ,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_spaces).check_illegal_chars())

        bad_tab = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg19,AAAAAA,D1\t,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_tab).check_illegal_chars())

        bad_question_mark = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A?1,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_question_mark).check_illegal_chars())
        
        bad_parentheses = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A(1),hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_parentheses).check_illegal_chars())
        
        bad_brackets = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg19,AAAAAA,D[1],N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_brackets).check_illegal_chars())

        bad_backslash = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg\\19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_backslash).check_illegal_chars())

        bad_fwdslash = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg19,AAAAAA,D1,/N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_fwdslash).check_illegal_chars())

        bad_equals = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg19,AAAAAA,D1,N,R1,user=,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_equals).check_illegal_chars())

        bad_plus = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg19,AAAAAA,D1,N,R1+,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_plus).check_illegal_chars())

        bad_angles = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg<19>,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_angles).check_illegal_chars())

        bad_colon = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg:19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_colon).check_illegal_chars())

        bad_semicolon = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A;1,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_semicolon).check_illegal_chars())

        bad_double_quotes = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A"1",hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_double_quotes).check_illegal_chars())

        bad_single_quotes = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A\'1,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_single_quotes).check_illegal_chars())

        bad_star = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1*,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_star).check_illegal_chars())

        bad_hat = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg^19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_hat).check_illegal_chars())

        bad_pipe = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A1,hg|19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_pipe).check_illegal_chars())

        bad_amper = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A&1,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_amper).check_illegal_chars())

        bad_period = 'FCID,Lane,SampleID,Sample,Ref,Index,Description,Control,Recipe,Operator,SampleProject\nbatch,1,A.1,hg19,AAAAAA,D1,N,R1,user,P1'
        self.assertFalse(samplesheet.SampleSheet(bad_period).check_illegal_chars())

    def test_check_index_lens(self):
        self.assertTrue(self.samplesheet_norm.check_index_lens())
        self.assertFalse(self.samplesheet_bad.check_index_lens())
        
    def test_check_duplicate_index_per_lane(self):
        self.assertTrue(self.samplesheet_norm.check_duplicate_index_per_lane())
        self.assertFalse(self.samplesheet_bad.check_duplicate_index_per_lane())

    def test_check_weird_chars(self):
        self.assertTrue(self.samplesheet_norm.check_weird_chars())
        self.assertFalse(self.samplesheet_bad.check_weird_chars())

    def test_check_sanity(self):
        self.assertTrue(self.samplesheet_norm.check_sanity())
        self.assertFalse(self.samplesheet_bad.check_sanity())


if __name__ == '__main__':
    unittest.main()
