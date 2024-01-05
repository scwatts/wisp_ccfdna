process SAMBAMBA_INDEX {
  tag "${meta.id}"

  container 'docker.io/scwatts/sambamba:1.0'

  input:
  tuple val(meta), path(bam)

  output:
  path('*bai')

  script:
  """
  sambamba index \\
    --nthreads ${task.cpus} \\
    ${meta.id}.bam
  """

  stub:
  """
  touch ${meta.id}.bam.bai
  """
}
