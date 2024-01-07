process SAMTOOLS_STATS {
  tag "${meta.id}"

  container 'docker.io/scwatts/samtools:1.19'

  input:
  tuple val(meta), path(bam)

  output:
  path "${meta.sample_id}.samtools_stats.txt"

  script:
  """
  samtools stats --threads ${task.cpus} ${bam} > ${meta.sample_id}.samtools_stats.txt
  """

  stub:
  """
  touch ${meta.sample_id}.samtools_stats.txt
  """
}
