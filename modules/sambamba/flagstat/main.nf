process SAMBAMBA_FLAGSTAT {
  tag "${meta.id}"

  container 'docker.io/scwatts/sambamba:1.0'

  input:
  tuple val(meta), path(bam)

  output:
  path "${meta.sample_id}.sambamba_flagstat.txt"

  script:
  """
  sambamba flagstat --nthreads ${task.cpus} ${bam} > ${meta.sample_id}.sambamba_flagstat.txt
  """

  stub:
  """
  touch ${meta.sample_id}.sambamba_flagstat.txt
  """
}
