#! bin/usr/env bash

#Make indices

gunzip data/hg19.chr1.fa.gz

bowtie2-build data/hg19.chr1.fa index/hg19.chr1

#Align reads with bowtie2 and then make a sorted bam file

bowtie2 -x index/hg19.chr1 -U data/factorx.chr1.fq.gz \
    | samtools sort -o results/factorx.sort.bam

#Making a bed graph file

bedtools genomecov -ibam results/factorx.sort.bam \
    -g data/hg19.chrom.sizes -bg \
    > results/factorx.bg

#Make BigWig file to create UCSC genome track

bedGraphToBigWig results/factorx.bg data/hg19.chrom.sizes \
    results/factorx.bw

#Peak calling with mac2

macs2 callpeak -t results/factorx.sort.bam -n results/factorx

#Generating motifs from peaks

bedtools getfasta -fi data/hg19.chr1.fa -bed results/factorx_peaks.narrowPeak \
    -fo results/factorx.peaks.fa

###Note: Tried running the above fasta file with meme, but took too long,
###so I made a file with 50 bp window around the factorx_summit

#Make narrower file from factorx_summits.bed

bedtools slop -i results/factorx_summits.bed \
    -g data/hg19.chrom.sizes -b 25 > results/factorx.summits.windows.fa

bedtools getfasta -fi data/hg19.chr1.fa \
    -bed results/factorx.summits.windows.bed \
    -fo results/factorx.summits.windows.fa

#NOTE, the meme code below takes a VERY LONG TIME to run!
meme results/factorx.summits.windows.fa -nmotifs 1 -maxw 20 -minw 8 -dna \
    -maxsize 10000000 -o results/meme

#NOTE: This text file is empty, so this code does nothing...
meme-get-motif -id 1 < results/meme/meme.txt

#To upload to github, you I needed to compress files. I also did not
#upload the index files because they were too large.
