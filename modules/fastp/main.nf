process FASTP {
  tag "${meta.id}"

  container 'docker.io/scwatts/fastp:0.23.4'

  input:
  tuple val(meta), path(reads_fwd), path(reads_rev)

  output:
  tuple val(meta), path('*R1*fastq.gz'), path('*R2*fastq.gz'), emit: fastq

  script:
  """
  # * do not apply trimming/clipping, already done in BCL convert
  # * split FASTQ into groups of 50,000,000 reads
  # * extract UMIs from read sequence

  fastp \\
    --in1 ${reads_fwd} \\
    --in2 ${reads_rev} \\
    --disable_adapter_trimming \\
    --split_by_lines 200000000 \\
    --umi \\
    --umi_loc per_read \\
    --umi_len 7 \\
    --umi_skip 1 \\
    --out1 ${meta.id}_R1.fastp.fastq.gz \\
    --out2 ${meta.id}_R2.fastp.fastq.gz
  """

  stub:
  """
  touch 00{1..4}.${meta.id}_R1.fastp.fastq.gz
  touch 00{1..4}.${meta.id}_R2.fastp.fastq.gz
  """
}
