include { BWA_MEM           } from '../modules/bwa/mem/main'
include { FASTP             } from '../modules/fastp/main'
include { MARKDUPS          } from '../modules/markdups/main'
include { SAMBAMBA_FLAGSTAT } from '../modules/sambamba/flagstat/main'
include { SAMBAMBA_INDEX    } from '../modules/sambamba/index/main'
include { SAMTOOLS_STATS    } from '../modules/samtools/stats/main'


workflow ALIGNMENT {
  take:
    ch_inputs         // channel: [meta_fastq]
    genome_fasta
    genome_fai
    genome_dict
    genome_bwa_index
    unmap_regions

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

    SAMBAMBA_INDEX(
      BWA_MEM.out.bam,
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

    // Reunite BAMs and BAIs, creating appropriate meta for grouping
    ch_bams_splits = WorkflowMain.groupByMeta(
      BWA_MEM.out.bam,
      SAMBAMBA_INDEX.out.bai,
    )
      .map { meta_split, bam, bai ->
        def meta_bam_split = [
          patient_id: meta_split.patient_id,
          sample_id: meta_split.sample_id,
        ]
        return [meta_bam_split, bam, bai]
      }

    // Group BAMs/BAIs by sample: [ meta, [bam, ..., ], [bai, ..., ] ]
    ch_markdups_inputs = ch_sample_fastq_counts
      .cross(ch_bams_splits)
      .map { fastq_counts_tuple, bams_splits_type ->
        def n = fastq_counts_tuple[1]
        def (meta_bam_split, bam, bai) = bams_splits_type

        def meta = [
          id: "${meta_bam_split.patient_id}_${meta_bam_split.sample_id}",
          *:meta_bam_split,
        ]

        return tuple(groupKey(meta, n), bam, bai)
      }
      .groupTuple()

    MARKDUPS(
      ch_markdups_inputs,
      genome_fasta,
      genome_fai,
      genome_dict,
      unmap_regions,
    )

    SAMBAMBA_FLAGSTAT(
      MARKDUPS.out.bam.map { meta, bam, bai -> [meta, bam] },
    )

    SAMTOOLS_STATS(
      MARKDUPS.out.bam.map { meta, bam, bai -> [meta, bam] },
    )

  emit:
    bam = MARKDUPS.out.bam
}
