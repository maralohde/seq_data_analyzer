include {abricate} from './process/abricate.nf'

workflow antibiotic_resistance_screening_wf{
    take:
		fasta // val(name), path(reads)
    main:
      abricate(fasta)
}