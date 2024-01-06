# WISP ccfDNA workflow

A rigid workflow to serve a single purpose in one specific environment

## Quick start

From FASTQ

```bash
cat <<EOF > samplesheet.csv
patient_id,sample_id,filetype,info,filepaths
alpha,baz,oncoanalyser,,s3://bucket/baz_oncoanalyser/
alpha,foo,fastq,library_id:bar;lane:001,s3://bucket/foo_L001_R1_001.fastq.gz;s3://bucket/foo_L001_R2_001.fastq.gz
alpha,foo,fastq,library_id:bar;lane:002,s3://bucket/foo_L002_R1_001.fastq.gz;s3://bucket/foo_L002_R2_001.fastq.gz

omega,qux,oncoanalyser,,s3://bucket/qux_oncoanalyser/
omega,fizz,fastq,library_id:buzz;lane:001,s3://bucket/fizz_L001_R1_001.fastq.gz;s3://bucket/fizz_L001_R2_001.fastq.gz
EOF

nextflow run -c nextflow.config_aws main.nf \
  -work-dir s3://bucket/work/ \
  --input samplesheet.csv \
  --genome_fasta s3://bucket/GRCh38.fasta \
  --genome_fai s3://bucket/GRCh38.fasta.fai \
  --genome_dict s3://bucket/GRCh38.fasta.dict \
  --genome_bwa_index s3://bucket/GRCh38/bwa_index/ \
  --refdata_unmap_regions s3://bucket/unmap_regions.tsv \
  --refdata_gc_profile s3://bucket/gc_profile.cnp \
  --refdata_diploid_regions s3://bucket/diploid_regions.bed \
  --outdir s3://bucket/output/
```

From BAM

```bash
cat <<EOF > samplesheet.csv
patient_id,sample_id,filetype,info,filepaths
alpha,baz,oncoanalyser,,s3://bucket/baz_oncoanalyser/
alpha,foo,bam,,s3://bucket/foo.bam

omega,qux,oncoanalyser,,s3://bucket/qux_oncoanalyser/
omega,fizz,bam,,s3://bucket/fizz.bam
EOF

nextflow run -c nextflow.config_aws main.nf \
  -work-dir s3://bucket/work/ \
  --input samplesheet.csv \
  --alignment_skip \
  --genome_fasta s3://bucket/GRCh38.fasta \
  --genome_fai s3://bucket/GRCh38.fasta.fai \
  --genome_dict s3://bucket/GRCh38.fasta.dict \
  --genome_bwa_index s3://bucket/GRCh38/bwa_index/ \
  --refdata_unmap_regions s3://bucket/unmap_regions.tsv \
  --refdata_gc_profile s3://bucket/gc_profile.cnp \
  --refdata_diploid_regions s3://bucket/diploid_regions.bed \
  --outdir s3://bucket/output/
```
