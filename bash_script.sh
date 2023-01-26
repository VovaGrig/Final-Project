#!/bin/sh
fastqc -outdir ../fastqc/ -t 8 ../../../Data/AI-69_S60_R1_001.fastq.gz ../../../Data/AI-69_S60_R2_001.fastq.gz
trimmomatic PE -phred33 -threads 8 data/raw_reads/AI-69_S60_R1_001.fastq.gz data/raw_reads/AI-69_S60_R2_001.fastq.gz -baseout trim1 LEADING:15 TRAILING:15 SLIDINGWINDOW:10:20 MINLEN:20
trimmomatic PE -phred33 -threads 8 data/rawreads/AI-69_S60_R1_001.fastq.gz data/rawreads/AI-69_S60_R2_001.fastq.gz -baseout trim1 LEADING:15 TRAILING:15 SLIDINGWINDOW:10:20 MINLEN:20
bwa index data/references/T5_sequence.fasta
fastqc --outdir=../fastqc/ trim1_1P trim1_2P
bwa mem -t 8 data/references/T5_sequence.fasta data/trims/trim1_1P data/trims/trim1_2P | samtools view -Sb > T5_AI_69_S60_aligned.bam
mkdir mapped
mkdir mapped_sorted
mkdir calling
mv T5_AI_69_S60_aligned.bam mapped
samtools sort -@ 8 mapped/T5_AI_69_S60_aligned.bam -o mapped_sorted/T5_AI_69_S60_aligned_sorted.bam
cd mapped_sorted/
ls
cd ../mapped
samtools view -h T5_AI_69_S60_aligned.bam | head 50
samtools view -h T5_AI_69_S60_aligned.bam | head -50
cd ../
samtools index mapped_sorted/T5_AI_69_S60_aligned_sorted.bam
bcftools mpileup -Ou -f data/references/T5_sequence.fasta mapped_sorted/T5_AI_69_S60_aligned_sorted.bam | bcftools call -Ou -mv --ploidy 1 | bcftools filter -s LowQual -e '%QUAL<20 || DP>100' > calling/T5_AI_69_S60_variants.vcf
cd calling/
rm *
cd ../
bcftools mpileup -Ou -f data/reference/T5_sequence.fasta mapped_sorted/T5_AI_69_S60_aligned_sorted.bam | bcftools call -Ou -mv --ploidy 1 | bcftools filter -s LowQual -e '%QUAL<20 || DP>100' > calling/T5_AI_69_S60_variants.vcf
bcftools mpileup -Ou -f data/references/T5_sequence.fasta mapped_sorted/T5_AI_69_S60_aligned_sorted.bam | bcftools call -Ou -mv --ploidy 1 | bcftools filter -s LowQual -e '%QUAL<20 || DP>100' > calling/T5_AI_69_S60_variants.vcf
less T5_AI_69_S60_variants.vcf
exit