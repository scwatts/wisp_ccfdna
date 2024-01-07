include { COBALT      } from '../modules/cobalt/main'
include { MARKDUPS    } from '../modules/markdups/main'
include { SAGE_APPEND } from '../modules/sage/append/main'
include { WISP        } from '../modules/wisp/main'


workflow WISP_ANALYSIS {
  take:
    ch_inputs         // channel: [meta_wisp, oncoanalyser_dir, bam]
    genome_fasta
    genome_fai
    genome_dict
    unmap_regions
    gc_profile
    diploid_bed

  main:

    ch_markdups_inputs = ch_inputs
      .map { meta, oncoanalyser_dir, bam ->
        return [meta, bam]
      }

    MARKDUPS(
      ch_markdups_inputs,
      genome_fasta,
      genome_fai,
      genome_dict,
      unmap_regions,
    )


    COBALT(
      MARKDUPS.out.bam,
      gc_profile,
      diploid_bed,
    )


    ch_sage_append_inputs = WorkflowMain.groupByMeta(
      ch_inputs.map { meta, oncoanalyser_dir, bam -> [meta, oncoanalyser_dir] },
      MARKDUPS.out.bam,
    )
      .map { meta, oncoanalyser_dir, bam ->
        def subpath = "/purple/${meta.primary_tumor_id}.purple.somatic.vcf.gz"
        def vcf = file(oncoanalyser_dir).toUriString() + subpath

        return [meta, vcf, bam]
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
      ch_inputs.map { meta, oncoanalyser_dir, bam -> [meta, oncoanalyser_dir] },
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
