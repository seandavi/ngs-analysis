#!/usr/bin/env python

import os
import sys
import unittest
from ngs import maf

RESOURCE_DIR = 'resources'
EXAMPLE_MAF = 'example.maf'
OUT_POS_SIMPLE = 'example.out.pos.report.simple'
OUT_POS_DETAILED = 'example.out.pos.report.detailed'
OUT_POS_TEST = 'example.out.pos.report.test'
OUT_GENE = 'example.out.gene.report'
OUT_GENE_TEST = 'example.out.gene.report.test'

class TestMafFileFunctions(unittest.TestCase):
    
    def setUp(self):
        self.example_maf = os.path.join(RESOURCE_DIR, EXAMPLE_MAF)
        self.out_pos_simple = os.path.join(RESOURCE_DIR, OUT_POS_SIMPLE)
        self.out_pos_detailed = os.path.join(RESOURCE_DIR, OUT_POS_DETAILED)
        self.out_pos_test = os.path.join(RESOURCE_DIR, OUT_POS_TEST)
        self.out_gene = os.path.join(RESOURCE_DIR, OUT_GENE)
        self.out_gene_test = os.path.join(RESOURCE_DIR, OUT_GENE_TEST)

    def test_parse_line(self):
        with maf.MafFile(self.example_maf, 'r') as maffile:
            # Read header
            line = maffile.readline()
            maf_record = maffile.parse_line(line)
            for k,v in maf_record.iteritems():
                self.assertEqual(k,v)

            # Read first record
            line = maffile.readline()
            maf_record = maffile.parse_line(line)
            self.assertEqual(len(maf_record.keys()), 32)
            self.assertEqual(maf_record['Hugo_Symbol'], 'GENE_A')
            self.assertEqual(maf_record['Reference_Allele'], 'A')
            self.assertEqual(maf_record['Sequencer'], 'Illumina HiSeq')

            # Read next record
            line = maffile.readline()
            maf_record = maffile.parse_line(line)
            self.assertEqual(maf_record['Variant_Classification'], 'Intron')

    def test_generate_pos_report(self):
        # Test simple
        with open(self.out_pos_test, 'w') as op:
            with maf.MafFile(self.example_maf, 'r') as maffile:
                poskey2samples = maffile.generate_pos_report(fout=op, detailed=False)
        with open(self.out_pos_test, 'r') as f:
            report_pos_test = f.read()
        with open(self.out_pos_simple, 'r') as f:
            report_pos_simple = f.read()
        self.assertEqual(report_pos_simple, report_pos_test)
        
        # Test detailed
        with open(self.out_pos_test, 'w') as op:
            with maf.MafFile(self.example_maf, 'r') as maffile:
                poskey2samples = maffile.generate_pos_report(fout=op, detailed=True)
        with open(self.out_pos_test, 'r') as f:
            report_pos_test = f.read()
        with open(self.out_pos_detailed, 'r') as f:
            report_pos_detailed = f.read()
        self.assertEqual(report_pos_detailed, report_pos_test)

    def test_generate_gene_report(self):
        with open(self.out_gene_test, 'w') as og:
            with maf.MafFile(self.example_maf, 'r') as maffile:
                g2c2varcounts, g2c2samples, g2c2samplepos = maffile.generate_gene_report(fout=og)
        with open(self.out_gene_test, 'r') as f:
            report_gene_test = f.read()
        with open(self.out_gene, 'r') as f:
            report_gene = f.read()
        self.assertEqual(report_gene, report_gene_test)


if __name__ == '__main__':
    unittest.main()
