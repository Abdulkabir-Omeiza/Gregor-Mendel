# for the entire data
#Then I created directories to separate the data
 
#for the entire data
for f in *.fastq.gz; do fastqc -t 10 -f fastq -noextract $f;
  	done

# this command is run in each directory containg a dataset corresponding to its name
for a in *.zip; do multiqc *zip -z -f  $a;
	done
#trimming
for g in *.fastq.gz; do fastp -i *_R1.fastq.gz -I *_R2.fastq.gz -o trimmed_R1.fastq.gz -O trimmed_R2.fastq.gz --qualified_quality_phred 20 --html report.html --json report.json $quality_control_output;
	done
#indexing
for i in  reference.fasta; do bwa index -a bwtsw reference.fasta $i;
        done
#Mapping
for b in trimmed_R1.fastq.gz trimmed_R2.fastq.gz; do bwa mem reference.fasta trimmed_R1.fastq.gz trimmed_R2.fastq.gz | samtools view -h -b -o DB.bam $b;
	done
#sorting
for s in *.bam; do bwa mem reference.fasta trimmed_R1.fastq.gz trimmed_R2.fastq.gz | samtools sort -o myfile_sorted.bam $s;
	done

#index sorted ban file
for n in *_sorted.bam; do samtools index myfile_sorted.bam $n;
	done

#variant calling
for t in *_sorted.bam; do freebayes -f reference.fasta myfile_sorted.bam >var_m.vcf $t;
	done
