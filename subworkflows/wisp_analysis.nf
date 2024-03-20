include { COBALT            } from '../modules/cobalt/main'
include { SAGE_APPEND       } from '../modules/sage/append/main'
include { WISP              } from '../modules/wisp/main'


workflow WISP_ANALYSIS {
  take:
    ch_inputs     // channel: [meta_wisp, oncoanalyser_dir, bam, bai]
    genome_fasta
    genome_fai
    genome_dict
    gc_profile
    diploid_bed

  main:
    COBALT(
      ch_inputs.map { meta_wisp, oncoanalyser_dir, bam, bai -> [meta_wisp, bam, bai] },
      gc_profile,
      diploid_bed,
    )

    ch_sage_append_inputs = ch_inputs
      .map { meta, oncoanalyser_dir, bam, bai ->
        def subpath = "/purple/${meta.primary_tumor_id}.purple.somatic.vcf.gz"
        def vcf = file(oncoanalyser_dir).toUriString() + subpath

        return [meta, vcf, bam, bai]
      }

    SAGE_APPEND(
      ch_sage_append_inputs,
      genome_fasta,
      genome_fai,
      genome_dict,
    )

    ch_wisp_inputs = WorkflowMain.groupByMeta(
      SAGE_APPEND.out.vcf,
      COBALT.out.cobalt_dir,
      ch_inputs.map { meta, oncoanalyser_dir, bam, bai -> [meta, oncoanalyser_dir] },
    )
      .map { meta, vcf, cobalt_dir, oncoanalyser_dir ->
        def purple_dir = file(oncoanalyser_dir).toUriString() + '/purple/'
        return [meta, vcf, cobalt_dir, purple_dir]
      }

    WISP(
      ch_wisp_inputs,
      genome_fasta,
      genome_fai,
    )
}
