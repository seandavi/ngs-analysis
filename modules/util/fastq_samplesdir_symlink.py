#!/usr/bin/env python

description = '''
Given a list of paths to fastqfiles, create sample directories and
create symbolic links to each of those files inside each sample
directory.
The sample directories will be created in the current directory
where this tool is run.
'''

import argparse
import os
import sys
from ngs import fastq

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('fastqfileslist',
                    help='List of paths to fastqfiles',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()

    for line in params.fastqfileslist:
        origfilepath = line.strip()
        # Make sure that the file exists
        if not os.path.exists(origfilepath):
            sys.stderr.write('Fastqfile %s does not exist. Exiting.\n\n' % origfilepath)
            sys.exit(1)

        # Create sample directory and symlink
        origfilepath_array = list(os.path.split(origfilepath))
        fastqfile = origfilepath_array[-1]
        samplename = fastq.IlluminaFastqFile.parse_filename(fastqfile).sample
        sample_dirname = '_'.join(['Sample', samplename])
        if not os.path.exists(sample_dirname):
            os.makedirs(sample_dirname)

        # Create symlink
        origfilepath_array.insert(0, '..')
        sourcefile = os.path.join(*origfilepath_array)
        destfile = os.path.join(sample_dirname, fastqfile)
        os.symlink(sourcefile, destfile)


if __name__ == '__main__':
    main()
