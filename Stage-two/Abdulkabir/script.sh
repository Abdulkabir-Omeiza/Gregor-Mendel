#!/bin/sh

wget https://zenodo.org/records/10426436/files/ERR8774458_1.fastq.gz && wget https://zenodo.org/records/10426436/files/ERR8774458_2.fastq.gz && wget https://zenodo.org/records/10886725/files/Reference.fasta
mkdir QC_Reports
fastqc *fastq.gz -O QC_Reports
fastp -i *1.fastq.gz -I *2.fastq.gz -o trimmed_R1.fastq -O trimmed_R2.fastq --qualified_quality_phred 20 --html report.html --json report.json
fastqc trimmed*.fastq -o QC_Reports
mkdir ref
cp Reference.fasta ref
cd ref
bwa index Reference.fasta
cd ..
bwa mem ref/Reference.fasta trimmed_R1.fastq trimmed_R2.fastq >  ERR8774458.sam
samtools view -S -b ERR8774458.sam > ERR8774458.bam
samtools sort ERR8774458.bam -o ERR8774458.sorted.bam
samtools flagstat ERR8774458.sorted.bam
samtools index ERR8774458.sorted.bam
bcftools mpileup -Ou -f Reference.fasta  ERR8774458.sorted.bam | bcftools call -Ov -mv > ERR8774458.vcf
mv Reference.fasta Reference.fasta.fai ref
mkdir trimmed
mv trimmed_R1.fastq trimmed_R2.fastq report.html report.json trimmed/
mkdir bam+sam_files
mv ERR8774458.sam ERR8774458.bam ERR8774458.sorted.bam ERR8774458.sorted.bam.bai bam+sam_files
mkdir raw_sequences
mv ERR8774458_1.fastq.gz ERR8774458_2.fastq.gz raw_sequences
echo vcf file is ERR8774458.vcf
