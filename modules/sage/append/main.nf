process SAGE_APPEND {
  tag "${meta.id}"

  container 'docker.io/scwatts/sage:3.4'

  input:
  tuple val(meta), path(vcf), path(bam), path(bai)
  path genome_fasta
  path genome_fai
  path genome_dict

  output:
  tuple val(meta), path('*vcf.gz'), emit: vcf
  path '*.vcf.gz.tbi'
  path '*.sage.bqr.tsv'
  path '*.frag_lengths.tsv.gz'

  script:
  """
  java \\
    -Xmx${Math.round(task.memory.bytes * 0.95)} \\
    -cp /opt/sage/sage.jar com.hartwig.hmftools.sage.append.SageAppendApplication \\
      -input_vcf ${vcf} \\
      -reference ${meta.sample_id} \\
      -reference_bam ${bam} \\
      \\
      -ref_genome ${genome_fasta} \\
      -ref_genome_version 38 \\
      \\
      -write_frag_lengths \\
      -threads ${task.cpus} \\
      \\
      -output_vcf ${meta.sample_id}.purple.somatic.vcf.gz
  """

  stub:
  """
  touch ${meta.sample_id}.purple.somatic.vcf.gz
  touch ${meta.sample_id}.vcf.gz.tbi
  touch ${meta.sample_id}.sage.bqr.tsv
  touch ${meta.sample_id}.frag_lengths.tsv.gz
  """
}

