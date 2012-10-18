#!/usr/bin/env python
description = '''
Generate plots using the output of GATK DepthOfCoverage
'''
import argparse
import os
import sys
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict
from random import randrange

def random_color(existing_colors):
    '''
    Return a random color that is not already in a set of existing colors
    '''
    while True:
        hexes = []
        for i in range(3):
            pair = hex(randrange(0, 255))[2:]
            if len(pair) == 1:
                pair = '0' + pair
            hexes.append(pair)
        c = "#%s" % "".join(hexes)
        if c not in existing_colors:
            existing_colors.add(c)
            return c

def filter_samplename(samplename):
    '''
    Filter sample name so that output is nice
    I.e. remove \'/\'s and the Depth_for prefix
    '''
    return os.path.split(samplename.replace('Depth_for_',''))[-1]

def create_single_plot(outfilename, x, y, title=None, xlabel=None, ylabel=None, color='k'):
    plt.figure()
    plt.plot(x, y, color)
    if title is not None:
        plt.suptitle(title)
    if xlabel is not None:
        plt.xlabel(xlabel)
    if ylabel is not None:
        plt.ylabel(ylabel)
    # Save image
    plt.savefig(outfilename, format='png')
    plt.close()

def plot_depthofcov_data(fin, outprefix):
    '''
    Read depthofcov data into memory
    '''
    # Load list of sample names
    line = fin.next()
    samples = map(filter_samplename, line.strip('\n').split('\t')[3:])

    # Read in data
    chrom2pos = defaultdict(list)
    chrom2totdp = defaultdict(list)
    chrom2avgdp = defaultdict(list)
    chrom2stdev = defaultdict(list)
    chrom2alldp = defaultdict(list)
    for line in fin:
        cols = line.strip('\n').split('\t')
        chrom, pos = cols[0].split(':')

        # Update values for each column
        chrom2pos[chrom].append(int(pos))
        chrom2totdp[chrom].append(int(cols[1]))
        chrom2avgdp[chrom].append(float(cols[2]))
        sample_depths = [int(x) for x in cols[3:]]
        chrom2alldp[chrom].append(sample_depths)
        chrom2stdev[chrom].append(np.std(sample_depths))

    # Generate a set of plots for each chromosome
    for chrom in chrom2pos:
        # Pos vs Total DP
        create_single_plot('.'.join([outprefix, chrom, 'totdp', 'png']),
                           chrom2pos[chrom],
                           chrom2totdp[chrom],
                           title='Pos vs Total DP',
                           xlabel='Position',
                           ylabel='Total DP',
                           color='b')

        # Pos vs Avg DP
        create_single_plot('.'.join([outprefix, chrom, 'avgdp', 'png']),
                           chrom2pos[chrom],
                           chrom2avgdp[chrom],
                           title='Pos vs Avg DP',
                           xlabel='Position',
                           ylabel='Avg DP',
                           color='b')
        
        # Pos vs Stdev
        create_single_plot('.'.join([outprefix, chrom, 'stdev', 'png']),
                           chrom2pos[chrom],
                           chrom2stdev[chrom],
                           title='Pos vs Stdev',
                           xlabel='Position',
                           ylabel='Standard Deviation',
                           color='b')

        # Individual sample depths
        sample_dps = zip(*chrom2alldp[chrom])
        for i,sample in enumerate(samples):
            create_single_plot('.'.join([outprefix, chrom, 'dp', sample, 'png']),
                               chrom2pos[chrom],
                               sample_dps[i],
                               title='%s Pos vs Depth' % sample,
                               xlabel='Position',
                               ylabel='Depth',
                               color='b')

        # Plot all samples onto same plot
        colors_used = set()
        plt.figure()
        for i,sample in enumerate(samples):
            plt.plot(chrom2pos[chrom], sample_dps[i], random_color(colors_used))
        plt.suptitle('All Samples Pos vs Depth')
        plt.xlabel('Position')
        plt.ylabel('Depth')
        plt.savefig('.'.join([outprefix, chrom, 'dp', 'allsamples', 'png']), format='png')
        plt.close()
        

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('depthofcov', 
                    help='Input GATK DepthOfCoverage output file suffixed .depthofcov', 
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    ap.add_argument('-o','--out-prefix',
                    help='Output prefix for all the figures',
                    type=str,
                    default='depthofcov.plot')
    params = ap.parse_args()

    with params.depthofcov as fin:
        plot_depthofcov_data(fin, params.out_prefix)
        
    
if __name__ == '__main__':
    main()
