process BWA_MEM {
  tag "${meta.id}"

  container 'docker.io/scwatts/bwa:0.7.17-sambamba'

  input:
  tuple val(meta), path(reads_fwd), path(reads_rev)
  path refgenome_fasta
  path refgenome_bwa_index

  output:
  tuple val(meta), path('*bam'), emit: bam

  script:
  """
  # TODO(SW): profile processes to assign appropriate CPU allocation, allow potential thrashing for now

  find ${refgenome_bwa_index} ! -type d -exec ln -s {} ./ \;

  bwa mem \\
    -t ${task.cpus} \\
    -R '@RG\tID:${meta.id}\tSM:${meta.sample_id}' \\
    -K 100000000 \\
    -Y \\
    ${reads_fwd} \\
    ${reads_rev} | \\
    \\
    sambamba view | \\
      --sam-input \\
      --format bam \\
      --compression-level 0 \\
      --nthreads ${task.cpus} | \\
    \\
    sambamba sort \\
      --nthreads ${task.cpus} \\
      --out ${meta.id}.${meta.split}.bam
  """

  stub:
  """
  touch ${meta.id}.${meta.split}.bam
  """
}
