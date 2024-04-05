mkdir stage2
cd stage2
wget https://zenodo.org/records/10426436/files/ERR8774458_1.fastq.gz
wget https://zenodo.org/records/10426436/files/ERR8774458_2.fastq.gz
mkdir ref
cd ref
wget https://zenodo.org/records/10886725/files/Reference.fasta
cd stage2
cd ..
cd ref
sudo apt-get install fastqc
cd ..
ls *.gz
fastqc *.fastq.gz
sudo apt-get install fastp
rm *trimmed
fastp -i *_1.fastq.gz -I *_2.fastq.gz -o trimmed_R1.fastq -O trimmed_R2.fastq --qualified_quality_phred 20 --html report.html --json report.json
fastqc trimmed_*.fastq
cd ref
sudo apt-get install bwa
bwa index -a bwtsw Reference.fasta
cd ..
bwa mem ref/Reference.fasta trimmed_R1.fastq trimmed_R2.fastq > ERR8774458.sam
cd ref
sudo apt-get install samtools
cd ..
samtools view -hbo ERR8774458.bam ERR8774458.sam
samtools sort ERR8774458.bam -o ERR8774458.sorted.bam
samtools index ERR8774458.sorted.bam
sudo apt-get install bcftools
bcftools mpileup -Ou -f ref/Reference.fasta ERR8774458.sorted.bam |bcftools call -Ov -mv > ERR8774458.vcf
less ERR8774458.vcf
sudo apt-get install tabix
bgzip VCF/Result.vcf
