workflow PREPARE_INPUTS {
  take:
    ch_samplesheet_fp // val: samplesheet filepath

  main:
    // channel:           [ meta ]
    // meta:              [ patient_id: str, oncoanalyser: meta_oncoanalyser, fastq: [ meta_fastq, ... ], bam: meta_bam ]
    // meta_oncoanalyser: [ patient_id: str, sample_id: str, path: str]
    // meta_fastq:        [ patient_id: str, sample_id: str, library_id: str, lane: str, id: str, reads_fwd: str, reads_rev: str ]
    // meta_bam:          [ patient_id: str, sample_id: str, bam: str ]
    ch_inputs = Channel.fromPath(ch_samplesheet_fp)
      .splitCsv(header: true)
      .map { d ->
        return [d['patient_id'], d]
      }
      .groupTuple()
      .map { patient_id, entries ->

        def meta = [
          'patient_id': patient_id,
          'oncoanalyser': [],
          'fastq': [],
          'bam': [],
        ]

        def remove_keys = ['filetype', 'info', 'filepaths']

        entries.each { d ->

          def meta_input = [
            *:d,
          ]

          d['info']
            .tokenize(';')
            .each { e ->
              def (k, v) = e.tokenize(':')
              meta_input[k] = v
            }

          if (d['filetype'] == 'fastq') {

            def (reads_fwd, reads_rev) = d['filepaths'].tokenize(';')
            meta_input['reads_fwd'] = reads_fwd
            meta_input['reads_rev'] = reads_rev

            meta_input['id'] = "${patient_id}_${meta_input.sample_id}_${meta_input.library_id}_${meta_input.lane}"

            meta['fastq'] << meta_input

          } else if (d['filetype'] == 'bam') {

            meta_input['bam'] = d['filepaths']

            meta['bam'] = meta_input

          } else if (d['filetype'] == 'oncoanalyser') {

            meta_input['path'] = d['filepaths']

            meta['oncoanalyser'] = meta_input

          } else {

            assert false

          }

          remove_keys.each { k -> meta_input.remove(k) }
        }

        return meta
      }

  emit:
    inputs = ch_inputs
}
