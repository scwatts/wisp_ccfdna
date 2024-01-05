process SAMBAMBA_MERGE {
  tag "${meta.id}"

  container 'docker.io/scwatts/sambamba:1.0'

  input:
  tuple val(meta), path(bams)

  output:
  tuple val(meta), path('*bam'), emit: bam

  script:
  """
  sambamba merge \\
    --nthreads ${task.cpus} \\
    ${meta.id}.bam \\
    ${bams}
  """

  stub:
  """
  touch ${meta.id}.bam
  """
}
