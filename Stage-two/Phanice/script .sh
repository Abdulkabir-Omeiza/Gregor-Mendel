#Install anaconda#

wget https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh 

#Assigning permissions to the file#

chmod +x Anaconda3-2024.02-1-Linux-x86_64.sh 

#execute anaconda#

./Anaconda3-2024.02-1-Linux-x86_64.sh 

#initiate conda channels#

conda config --add channels
conda config --add channels bioconda
conda config --add channels conda~forge
conda config --show channels 
conda create -n varriant_calling fastqc multiqc bwa samtools freebayes bcftool tabix
conda config --show-sources
sudo apt install fastqc
sudo apt install multiqc
sudo apt install bwa freebayes bcftools samtools tabix
conda activate variant-calling
conda create variant_calling
conda create -n variant_calling
 
 #Creating directory and downloading datasets#
 
mkdir pipeline_testing && cd pipeline_testing
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/ACBarrie_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/ACBarrie_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Alsen_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Alsen_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Baxter_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Baxter_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Chara_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Chara_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Drysdale_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/raw/main/dataset/raw_reads/Drysdale_R2.fastq.gz

#RUNNING fastqc#

fastqc *.fastq.gz

browse ACBarrie_R1_fastqc.html 

#RUNINNG multiqc#

multiqc *_fastqc.zip

browse multiqc_report.html 
  
  
  #TRIMMING#
  
#INSTALL BBTOOLS
sudo apt install bbtools

#REPAIR THE FILES
 #ACBarrie
 
 repair.sh -Xmx14g  in1=ACBarrie_R1.fastq.gz  in2=ACBarrie_R2.fastq.gz  out1=ACBarrie_repairedR1.fastq.gz  out2=ACBarrie_repairedR2.fastq.gz
 
 fastp -i ACBarrie_repairedR1.fastq.gz -I ACBarrie_repairedR2.fastq.gz -o ACBarrie_cleanR1.fastq.gz -O ACBarrie_cleanR2.fastq.gz --html ACBarrie.html --json ACBarrie.json 
  
  #TO VISUALIZE
  browse ACBarrie.html 

#Drysdale

repair.sh -Xmx14g  in1=Drysdale_R1.fastq.gz   in2=Drysdale_R2.fastq.gz  out1=Drysdale_repairedR1.fastq.gz  out2=Drysdale_repairedR2.fastq.gz
 
fastp -i Drysdale_repairedR1.fastq.gz -I Drysdale_repairedR2.fastq.gz -o Drysdale_cleanR1.fastq.gz -O Drysdale_cleanR2.fastq.gz --html Drysdale.html --json Drysdale.json
 
 #to visualize
 browse Drysdale.html
 
 #Alsen
 
 repair.sh -Xmx14g  in1=Alsen_R1.fastq.gz   in2=Alsen_R2.fastq.gz  out1=Alsen_repairedR1.fastq.gz  out2=Alsen_repairedR2.fastq.gz
 
 fastp -i Alsen_repairedR1.fastq.gz -I Alsen_repairedR2.fastq.gz -o Alsen_cleanR1.fastq.gz -O Alsen_cleanR2.fastq.gz --html Alsen.html --json Alsen.json

 #to visualize
  browse Alsen.html 


#Baxter

repair.sh -Xmx14g  in1=Baxter_R1.fastq.gz   in2=Baxter_R2.fastq.gz  out1=Baxter_repairedR1.fastq.gz  out2=Baxter_repairedR2.fastq.gz

fastp -i Baxter_repairedR1.fastq.gz -I Baxter_repairedR2.fastq.gz -o Baxter_cleanR1.fastq.gz -O Baxter_cleanR2.fastq.gz --html Baxter.html --json Baxter.json

#to visualize
browse Baxter.html

#Chara

repair.sh -Xmx14g  in1=Chara_R1.fastq.gz  in2=Chara_R2.fastq.gz  out1=Chara_repairedR1.fastq.gz  out2=Chara_repairedR2.fastq.gz
 
 fastp -i Chara_repairedR1.fastq.gz -I Chara_repairedR2.fastq.gz -o Chara_cleanR1.fastq.gz -O Chara_cleanR2.fastq.gz --html Chara.html --json Chara.json 

# to visualize
browse Chara.html 

#MAPPING

bwa index Reference.fasta
 ref=Reference.fasta
 read1=Baxter_repairedR1.fastq.gz
 read2=Baxter_repairedR2.fastq.gz
 RGID="000"
 RGSN="Baxter"
 readgroup="@RG\\tID:{RGID}\\tPL:Illumina\\tPU:None\\tLB:None\\tSM:${RGSN}"
 
 mkdir BAMS
 cd BAMS
 bwa mem -t 8 -R "readgroup" $ref $read1 $read2|samtools view -h -b -o Baxter.raw.bam

samtools flagstat Baxter.raw.bam

samtools sort -@ 8 -n Baxter.filtered.bam -o Baxter.sorted.n.bam

samtools fixmate -m Baxter.sorted.n.bam Baxter.fixmate.bam
 
 samtools sort -@ 8 Baxter.fixmate.bam -o Baxter.sorted.p.bam
 
 samtools markdup -r -@ 8 Baxter.sorted.p.bam Baxter.dedup.bam
 
 samtools index Baxter.dedup.bam

bcftools mpileup -Ou -f Reference.fasta Baxter.dedup.bam | bcftools call -mv -Ov -o Baxter.vcf

