process MARKDUPS {
  tag "${meta.id}"

  container 'docker.io/scwatts/markdups:1.1.rc1'

  input:
  tuple val(meta), path(bam)
  path genome_fasta
  path genome_fai
  path genome_dict
  path unmap_regions

  output:
  tuple val(meta), path('*bam'), emit: bam
  path '*.tsv'

  script:
  """
  java \\
    -Xmx${Math.round(task.memory.bytes * 0.95)} \\
    -jar /opt/markdups/markdups.jar \\
      \\
      -samtools \$(which samtools) \\
      -sambamba \$(which sambamba) \\
      \\
      -sample ${meta.sample_id} \\
      -input_bam ${bam} \\
      \\
      -form_consensus \\
      -multi_bam \\
      -umi_enabled \\
      -umi_duplex \\
      -umi_duplex_delim _ \\
      -umi_base_diff_stats \\
      \\
      -unmap_regions ${unmap_regions} \\
      -ref_genome ${genome_fasta} \\
      -ref_genome_version 38 \\
      \\
      -write_stats \\
      -threads 16 \\
      \\
      -output_bam ${meta.sample_id}.mark_dups.bam
  """

  stub:
  """
  touch ${meta.sample_id}.mark_dups.bam
  touch ${meta.sample_id}.duplicate_freq.tsv
  touch ${meta.sample_id}.umi_coord_freq.tsv
  touch ${meta.sample_id}.umi_edit_distance.tsv
  touch ${meta.sample_id}.umi_nucleotide_freq.tsv
  """
}
