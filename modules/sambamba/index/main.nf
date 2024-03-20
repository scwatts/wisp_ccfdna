process SAMBAMBA_INDEX {
  tag "${meta.id}"

  container 'docker.io/scwatts/sambamba:1.0'

  input:
  tuple val(meta), path(bam)

  output:
  tuple val(meta), path('*bai'), emit: bai

  script:
  """
  sambamba index \\
    --nthreads ${task.cpus} \\
    ${bam}
  """

  stub:
  """
  touch ${bam}.bai
  """
}
