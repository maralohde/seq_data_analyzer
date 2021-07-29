include {download_db} from './process/download_db.nf'
include {sourmash_classification; sourmash_signatures} from './process/sourmash'


workflow taxonomy_classification_wf {
	take:
		fastq_illumina_se  // val(name), path(reads)
	main:
		download_db()
		sourmash_signatures(fastq_illumina_se)
		sourmash_classification(sourmash_signatures.out, download_db.out)
}

