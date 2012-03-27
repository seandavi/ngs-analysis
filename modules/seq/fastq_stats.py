#!/usr/bin/python -tt
#
#
# Read in a fastq file and generate stats about the sequences
#
#

import argparse
import sys

def fastq_stats(fastqfile):
    file_ext = fastqfile.split('.')[-1]
    if file_ext == 'gz':
        import gzip
        f = gzip.GzipFile(fastqfile, 'r')
    elif file_ext == 'zip':
        import zipfile
        f = zipfile.ZipFile(fastqfile, 'r')
    else:
        f = open(fastqfile, 'r')
    sequences = 0
    num_reads = 0
    length_hist = {}
    t = 0
    for line in f:
        if t % 4 == 1:
            seq_len = len(line.strip())
            sequences += seq_len
            num_reads += 1
            
            if seq_len in length_hist:
                length_hist[seq_len] += 1
            else:
                length_hist[seq_len] = 1
        t += 1
    f.close()
    return num_reads, sequences, length_hist

def get_report(fastqfile, paired=None):
    read1_reads, read1_seqs, read1_hist = fastq_stats(fastqfile)
    if paired is None:
        return read1_reads, read1_seqs, read1_hist
    else:
        read2_reads, read2_seqs, read2_hist = fastq_stats(paired)
        return read1_reads, read1_seqs, read1_hist, read2_reads, read2_seqs, read2_hist

def main():
    # Set up command line arguments
    ap = argparse.ArgumentParser(description='Generate stats about the sequences in a fastq file')
    # Required args
    ap.add_argument('fastqfile', help='fastq file containing the sequence records')
    # Optional args
    ap.add_argument('-p', '--paired-file', help='fastq file containing second read')
    ap.add_argument('-l', '--length-hist', help='filename where a histogram of sequence lengths is outputted')
    params = ap.parse_args()

    # Generate the stats
    stats = get_report(params.fastqfile, params.paired_file)

    # Print to standard out
    if params.paired_file:
        sys.stdout.write("Read 1 number of reads: %i\n" % stats[0])
        sys.stdout.write("Read 1 sequences: %i\n" % stats[1])
        sys.stdout.write("Read 2 number of reads: %i\n" % stats[3])
        sys.stdout.write("Read 2 sequences: %i\n" % stats[4])
        sys.stdout.write("Total sequences: %i\n" % (stats[1] + stats[4]))
    else:
        sys.stdout.write("Reads: %i\n" % stats[0])
        sys.stdout.write("Sequences: %i\n" % stats[1])

    # Handle output of histogram(s)
    if params.length_hist:
        hists = [stats[2]]
        if params.paired_file:
            hists.append(stats[5])
    
        # Find maximum read length
        max_len = -1
        for h in hists:
            m_ = max(h.keys())
            if max_len < m_:
                max_len = m_

        f = open(params.length_hist,'w')
        for i in range(max_len + 1):
            out_arr = []
            for h in hists:
                if i in h:
                    num_counts = h[i]
                else:
                    num_counts = 0
                out_arr.append(str(num_counts))

            f.write('%i\t%s\n' % (i, '\t'.join(out_arr)))
        f.close()
        

if __name__ == '__main__':
    main()
