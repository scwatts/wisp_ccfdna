process COBALT {
  tag "${meta.id}"

  container 'docker.io/scwatts/cobalt:1.16.rc1'

  input:
  tuple val(meta), path(bam)
  path gc_profile
  path diploid_bed

  output:
  tuple val(meta), path('cobalt'), emit: cobalt_dir

  script:
  """
  java \\
    -Xmx${Math.round(task.memory.bytes * 0.95)} \\
    -jar /opt/cobalt/cobalt.jar \\
      -tumor ${meta.sample_id} \\
      -tumor_bam ${bam} \\
      \\
      -gc_profile ${gc_profile} \\
      -tumor_only_diploid_bed ${diploid_bed} \\
      \\
      -threads ${task.cpus} \\
      \\
      -output_dir cobalt/
  """

  stub:
  """
  mkdir -p cobalt/
  """
}
