process WISP {
  tag "${meta.id}"

  container 'docker.io/scwatts/wisp:1.1.rc1'

  input:
  tuple val(meta), path(vcf), path(cobalt_dir), path(purple_dir)
  path genome_fasta
  path genome_fai

  output:
  path 'wisp'

  script:
  """
  mkdir -p wisp/

  java \\
    -Xmx${Math.round(task.memory.bytes * 0.95)} \\
    -cp /opt/wisp/wisp.jar com.hartwig.hmftools.wisp.purity.PurityEstimator \\
      -patient_id ${meta.patient_id} \\
      -tumor_id ${meta.primary_tumor_id} \\
      -ctdna_samples ${meta.sample_id} \\
      \\
      -somatic_vcf ${vcf} \\
      -cobalt_dir ${cobalt_dir} \\
      -purple_dir ${purple_dir} \\
      \\
      -ref_genome ${genome_fasta} \\
      \\
      -gc_ratio_min 0 \\
      -write_types ALL \\
      -log_debug \\
      \\
      -output_dir wisp/
  """

  stub:
  """
  mkdir -p wisp/
  touch wisp/hello
  """
}
