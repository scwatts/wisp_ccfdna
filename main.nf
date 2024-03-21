include { ALIGNMENT }     from './subworkflows/alignment.nf'
include { PREPARE_INPUTS } from './subworkflows/prepare_inputs.nf'
include { WISP_ANALYSIS } from './subworkflows/wisp_analysis.nf'


workflow {

  // channel:           [ meta ]
  // meta:              [ patient_id: str, oncoanalyser: meta_oncoanalyser, fastq: [ meta_fastq, ... ], bam: meta_bam ]
  // meta_oncoanalyser: [ patient_id: str, sample_id: str, path: str]
  // meta_fastq:        [ patient_id: str, sample_id: str, library_id: str, lane: str, id: str, reads_fwd: str, reads_rev: str ]
  // meta_bam:          [ patient_id: str, sample_id: str, bam: str ]
  PREPARE_INPUTS(
    params.input,
  )
  ch_inputs = PREPARE_INPUTS.out.inputs

  ch_bams = Channel.empty()
  if (!params.alignment_skip) {

    ch_alignment_inputs = ch_inputs.flatMap { meta -> meta['fastq'] }

    ALIGNMENT(
      ch_alignment_inputs,
      file(params.genome_fasta),
      file(params.genome_fai),
      file(params.genome_dict),
      file(params.genome_bwa_index),
      file(params.refdata_unmap_regions),
    )

    ch_bams = ALIGNMENT.out.bam

  } else {

    ch_bams = ch_inputs
      .map { meta ->
        def meta_bam = meta['bam']
        def bam = file(meta_bam['bam'])
        def bai = "${bam.toUriString()}.bai"
        return [meta_bam, bam, bai]
      }

  }

  ch_wisp_inputs = WorkflowMain.groupByMeta(
      ch_inputs.map { meta -> [meta['patient_id'], meta['oncoanalyser']] },
      ch_bams.map { meta, bam, bai -> [meta['patient_id'], [meta, bam, bai]] },
  )
    .map { patient_id, meta_oncoanalyser, meta_bam, bam, bai ->
      def meta_wisp = [
        id: "${meta_bam.patient_id}_${meta_bam.sample_id}",
        patient_id: meta_bam.patient_id,
        sample_id: meta_bam.sample_id,
        primary_tumor_id: meta_oncoanalyser.sample_id,
      ]
      return [meta_wisp, file(meta_oncoanalyser['path']), bam, bai]
    }

  WISP_ANALYSIS(
    ch_wisp_inputs,
    file(params.genome_fasta),
    file(params.genome_fai),
    file(params.genome_dict),
    file(params.refdata_gc_profile),
    file(params.refdata_diploid_regions),
  )
}
