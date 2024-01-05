# ccfDNA alignment workflow

A rigid workflow to serve a single purpose in one specific environment

```bash
cat <<EOF > samplesheet.csv
sample_id,library_id,lane,reads_fwd,reads_rev
foo,bar,001,s3://bucket/foo_L001_R1_001.fastq.gz,s3://bucket/foo_L001_R2_001.fastq.gz
foo,bar,002,s3://bucket/foo_L002_R1_001.fastq.gz,s3://bucket/foo_L002_R2_001.fastq.gz
fizz,buzz,001,s3://bucket/fizz_L001_R1_001.fastq.gz,s3://bucket/fizz_L001_R2_001.fastq.gz
EOF

nextflow run main.nf \
  -work-dir s3://bucket/work/ \
  --refgenome_fasta s3://bucket/GRCh38.fasta \
  --refgenome_bwa_index s3://bucket/GRCh38/bwa_index/ \
  --outdir s3://bucket/output/
```
