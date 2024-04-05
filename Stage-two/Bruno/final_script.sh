#!/bin/bash

# Download FASTQ files
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/ACBarrie_R1.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/ACBarrie_R2.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Alsen_R1.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Alsen_R2.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Baxter_R1.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Baxter_R2.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Chara_R1.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Chara_R2.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Drysdale_R1.fastq.gz \
     https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Drysdale_R2.fastq.gz \
     https://raw.githubusercontent.com/josoga2/yt-dataset/main/dataset/raw_reads/reference.fasta

# Create directory for QC Reports
mkdir -p QC_Reports

# Run FastQC on downloaded FASTQ files
fastqc *.fastq.gz -o QC_Reports

# Make directory for trimming output
mkdir -p trimming-output

# Array of sample names
SAMPLES=("ACBarrie" "Alsen" "Baxter" "Chara" "Drysdale")

# Perform trimming using fastp for each sample
for SAMPLE in "${SAMPLES[@]}"; do
    fastp \
    -i "${SAMPLE}_R1.fastq.gz" \
    -I "${SAMPLE}_R2.fastq.gz" \
    -o "trimming-output/${SAMPLE}_trimmed_R1.fastq.gz" \
    -O "trimming-output/${SAMPLE}_trimmed_R2.fastq.gz" \
    --qualified_quality_phred 20 --html "report_${SAMPLE}.html"
done

cp reference.fasta trimming-output
cd trimming-output
bwa index reference.fasta
cd ..
mkdir -p vcf-file
for SAMPLE in "${SAMPLES[@]}"; do
    bwa mem trimming-output/reference.fasta trimming-output/${SAMPLE}_trimmed_R1.fastq.gz trimming-output/${SAMPLE}_trimmed_R2.fastq.gz > ${SAMPLE}.sam
    samtools view -S -b ${SAMPLE}.sam > ${SAMPLE}.bam
    samtools sort ${SAMPLE}.bam -o ${SAMPLE}.sorted.bam
    samtools flagstat ${SAMPLE}.sorted.bam
    bcftools mpileup -Ou -f trimming-output/reference.fasta ${SAMPLE}.sorted.bam | bcftools call -Ov -mv > ${SAMPLE}.vcf
    mv ${SAMPLE}.vcf vcf-file
    mkdir -p bam+sam_files
    mkdir -p raw_sequences
    mkdir -p html_files
    mv report_${SAMPLE}.html html_files
    mv ${SAMPLE}.sam ${SAMPLE}.bam ${SAMPLE}.sorted.bam bam+sam_files
    mv ${SAMPLE}_R1.fastq.gz ${SAMPLE}_R2.fastq.gz raw_sequences
done

echo "The output files are in the vcf-file directory"
