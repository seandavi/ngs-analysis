#!/usr/bin/env python
description = '''
Load gene2transcript mapping data to sqlite
Input file must have the following columns:

gene_name
gene_id
transcript_id
'''

import argparse
import csv
import sqlite3
import sys

DB_NAME='ensembl.db'
TABLE_NAME='gene2transcript'

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file',
                    help='Input file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()

    # Open connection
    conn = sqlite3.connect(DB_NAME)
    with conn:
        c = conn.cursor()

        # Check if table exists and if it does, delete
        c.execute('DROP TABLE IF EXISTS %s' % TABLE_NAME)
        
        # Create table
        c.execute('''CREATE TABLE %s (gene_name TEXT,
                                      gene_id TEXT,
                                      transcript_id TEXT)''' % TABLE_NAME)
        
        # Create indices for fast searching
        c.execute("CREATE INDEX gene2transcript_idx_gene_name ON %s (gene_name)" % TABLE_NAME)
        c.execute("CREATE INDEX gene2transcript_idx_transcript_id ON %s (transcript_id)" % TABLE_NAME)

        # Load file to table (fast)
        f = csv.reader(params.file, delimiter='\t')
        c.executemany("INSERT INTO %s VALUES (?,?,?)" % TABLE_NAME, f)

    # Close input file stream
    params.file.close()


if __name__ == '__main__':
    main()
