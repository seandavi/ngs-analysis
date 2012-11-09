#!/usr/bin/env python

import os
import unittest
from ngs import annovar

RESOURCE_DIR = 'resources'
ANNOVAR_CSV_FILE = 'example.annovar.csv'

class TestAnnovarCsv(unittest.TestCase):
    
    def setUp(self):
        # Load normal samplesheet
        self.annovar_csv_file = os.path.join(RESOURCE_DIR, ANNOVAR_CSV_FILE)
        self.filter_factory = annovar.AnnovarCsvFilterFactory()
#     def test_load_data(self):
#         annovar_csv = annovar.AnnovarCsv()
#         annovar_csv.load_data(self.annovar_csv_file)
#         self.assertEqual(len(annovar_csv.data['Func']), 3)

    def test_next(self):
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            row = reader.next()
            self.assertEqual(row[1], 'SAMD11')
            self.assertEqual(row[3], 'NM_152486:c.C369G:p.P123P')

            row = reader.next()
            self.assertEqual(row[1], 'SAMD11')

            row = reader.next()
            self.assertEqual(row[0], 'splicing')
            self.assertEqual(row[1], 'NOC2L')

    def test_filtered_variants(self):
        # Test gene filter
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_genes_filter(set(['SAMD11'])))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 1)

        # Test gene selector
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_genes_selector(set(['SAMD11'])))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 2)

        # Test dbSNP filter
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_dbSNP_filter())
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 1)
        # Test dbSNP selector
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_dbSNP_selector())
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 2)

        # Test multiple (gene selector and dbSNP filter
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_genes_selector(set(['SAMD11'])))
            reader.add_filter(self.filter_factory.create_dbSNP_filter())
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 1)

        # Test polyphen prediction
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_polyphen_pred_selector(set(['D'])))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 2)
        
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_polyphen_pred_selector(set(['D', 'B'])))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 3)


        # Test 1000 Genomes filter
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_1000Genomes_maf_selector(equalval=0.04))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 1)

        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_1000Genomes_maf_selector(minval=0.44, maxval=1))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 2)

        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_1000Genomes_maf_selector(minval=0.45, maxval=1))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 1)

        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_1000Genomes_maf_selector(maxval=1))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 3)

        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            reader.add_filter(self.filter_factory.create_1000Genomes_maf_selector(maxval=0.44))
            count = 0
            for row in reader.filtered_variants():
                count += 1
            self.assertEqual(count, 2)

    def test_count(self):
        with open(self.annovar_csv_file, 'r') as f:
            reader = annovar.AnnovarCsv(f)
            col2varcounts, col2genes = reader.count('ExonicFunc')
            self.assertEqual(col2varcounts['synonymous SNV'], 2)
            self.assertEqual(col2varcounts['nonsynonymous SNV'], 1)
            self.assertEqual(len(col2genes['synonymous SNV']), 2)
            self.assertEqual(len(col2genes['nonsynonymous SNV']), 1)
            self.assertTrue('SAMD11' in col2genes['synonymous SNV'])
            self.assertTrue('NOC2L' in col2genes['synonymous SNV'])                      


if __name__ == '__main__':
    unittest.main()
