process BWA_MEM {
  tag "${meta.id}"

  container 'docker.io/scwatts/bwa:0.7.17-sambamba'

  input:
  tuple val(meta), path(reads_fwd), path(reads_rev)
  path genome_fasta
  path genome_bwa_index

  output:
  tuple val(meta), path('*bam'), emit: bam

  script:
  """
  # TODO(SW): profile processes to assign appropriate CPU allocation, allow potential thrashing for now

  ln -s \$(find -L ${genome_bwa_index} -type f) ./

  bwa mem \\
    -Y \\
    -R '@RG\\tID:${meta.id}\\tSM:${meta.sample_id}' \\
    -K 100000000 \\
    -t ${task.cpus} \\
    ${genome_fasta} \\
    ${reads_fwd} \\
    ${reads_rev} | \\
    \\
    sambamba view \\
      --sam-input \\
      --format bam \\
      --compression-level 0 \\
      --nthreads ${task.cpus} \\
      /dev/stdin | \\
    \\
    sambamba sort \\
      --nthreads ${task.cpus} \\
      --out ${meta.sample_id}.${meta.library_id}.${meta.lane}.${meta.split}.bam \\
      /dev/stdin
  """

  stub:
  """
  touch ${meta.sample_id}.${meta.library_id}.${meta.lane}.${meta.split}.bam
  """
}
