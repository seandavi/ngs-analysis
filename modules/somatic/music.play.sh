#!/bin/bash


#genome music play \
#        --bam-list bamlist.txt
#        ?--numeric-clinical-data-file input/numeric_clinical_data.csv \
#        ?--maf-file input/myMAF.tsv \
#        --output-dir play_output \
#        ?--pathway-file input/pathway_db \
#        --reference-sequence /mnt/isilon/home/adminrig/Genome/hg19Fasta/hg19.fasta \
#        --roi-file /mnt/isilon/home/adminrig/Genome/SureSelect/SureSelect_All_Exon_50mb_with_annotation_hg19_bed \
#        ?--genetic-data-type gene

genome music play \
        --bam-list bamlist.txt \
        --numeric-clinical-data-file input/numeric_clinical_data.csv \
        --maf-file input/myMAF.tsv \
        --output-dir play_output \
        --pathway-file input/pathway_db \
        --reference-sequence /mnt/isilon/home/adminrig/Genome/hg19Fasta/hg19.fasta \
        --roi-file /mnt/isilon/home/adminrig/Genome/SureSelect/SureSelect_All_Exon_50mb_with_annotation_hg19_bed \
        --genetic-data-type gene
