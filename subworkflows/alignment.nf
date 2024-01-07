include { BWA_MEM        } from '../modules/bwa/mem/main'
include { FASTP          } from '../modules/fastp/main'
include { SAMBAMBA_INDEX } from '../modules/sambamba/index/main'
include { SAMBAMBA_MERGE } from '../modules/sambamba/merge/main'


workflow ALIGNMENT {
  take:
    ch_inputs         // channel: [meta_fastq]
    genome_fasta
    genome_bwa_index

  main:
    ch_fastp_inputs = ch_inputs
      .map { meta ->
        return [meta, file(meta.reads_fwd), file(meta.reads_rev)]
      }

    FASTP(
      ch_fastp_inputs,
    )


    ch_bwa_mem_inputs = FASTP.out.fastq
      .flatMap { meta, reads_fwd, reads_rev ->

        def data = [reads_fwd, reads_rev]
          .transpose()
          .collect { fwd, rev ->

            def split_fwd = fwd.name.replaceAll('\\..+$', '')
            def split_rev = rev.name.replaceAll('\\..+$', '')

            assert split_fwd == split_rev

            def meta_split = [
              *:meta,
              split: split_fwd,
            ]

            return [meta_split, fwd, rev]
          }

        return data
      }

    BWA_MEM(
      ch_bwa_mem_inputs,
      genome_fasta,
      genome_bwa_index,
    )


    // Here we block until all sample BAMs are complete so that we can merge into a single BAM
    // Hence, it is safe now to calculate FASTQ splits for a sample across all lanes
    ch_sample_fastq_counts = FASTP.out.fastq
      .map { meta, reads_fwd, reads_rev ->

        def fwd_count = reads_fwd.size()
        def rev_count = reads_rev.size()

        assert fwd_count == rev_count

        def meta_count = [
          patient_id: meta.patient_id,
          sample_id: meta.sample_id,
        ]

        return [meta_count, fwd_count]
      }
      .groupTuple()
      .map { meta_count, counts ->
        return [meta_count, counts.sum()]
      }


    // Add sample FASTQ counts to each split BAM so that we can group without blocking other samples
    ch_sambamba_merge_inputs = ch_sample_fastq_counts
      .cross(
        BWA_MEM.out.bam.map { meta, bam -> return [[patient_id: meta.patient_id, sample_id: meta.sample_id], bam] }
      )
      .map { count_tuple, bam_tuple ->
        def n = count_tuple[1]
        def (meta_bam, bam) = bam_tuple

        def meta = [
          id: "${meta_bam.patient_id}_${meta_bam.sample_id}",
          *:meta_bam,
        ]

        return tuple(groupKey(meta, n), bam)
      }
      .groupTuple()

    SAMBAMBA_MERGE(
      ch_sambamba_merge_inputs,
    )


    SAMBAMBA_INDEX(
      SAMBAMBA_MERGE.out.bam,
    )

  emit:
    bam = SAMBAMBA_MERGE.out.bam
}
