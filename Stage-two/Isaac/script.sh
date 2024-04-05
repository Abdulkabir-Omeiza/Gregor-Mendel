1 mkdir stage2
2 wget https://zenodo.org/records/10426436/files/ERR8774458_1.fastq.gz
3 wget https://zenodo.org/records/10426436/files/ERR8774458_2.fastq.gz
4  mkdir ref
5  wget https://zenodo.org/records/10886725/files/Reference.fasta
6  cd ..
7  ls
8  sudo apt-get install fastqc
9  fastqc *.fastq.gz
10 ls -lh
11 sudo apt-get install fastp
12 fastp -i *_1.fastq.gz -I *_2.fastq.gz -o trimmed_R1.fastq -O trimmed_R2.fastq --qualified_quality_phred 20 --html report.html --json report.json
13 clear
14  ls
15  fastqc trimmed_*.fastq
16  ls -lh
17  cd ref
18  sudo apt-get install bwa
19  bwa index -a bwtsw Reference.fasta
20  ls
21  cd ..
22  bwa mem ref/Reference.fasta trimmed_R1.fastq trimmed_R2.fastq > ERR8774458.sam
23  cd ref
24  sudo apt-get instal samtools
25  samtools view -hbo ERR8774458.bam ERR8774458.sam 
26  cd ..
27  samtools view -hbo ERR8774458.bam ERR8774458.sam 
28  cd ref
29  sudo apt-get install samtools
30  samtools view -hbo ERR8774458.bam ERR8774458.sam 
31  cd ..
32  samtools view -hbo ERR8774458.bam ERR8774458.sam
33  ls
34  ls -lh
35  samtools sort ERR8774458.bam -o ERR8774458.sorted.bam
36  ls -lh
37  samtools index ERR8774458.sorted.bam
38  ls -lh
39 sudo apt-get install bcftools
40 bcftools mpileup -Ou -f ref/Reference.fasta ERR8774458.sorted.bam | bcftools call -Ov -mv > ERR88774458.vcf
41  ls
42  ls -lh
43  clear
44  less ERR88774458.vcf  
