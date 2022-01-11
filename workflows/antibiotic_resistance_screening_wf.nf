include { abricate } from './process/abricate.nf'

workflow antibiotic_resistance_screening_wf {
    take: 
        fasta_input //tuple val(fasta_basename) path(fasta_file)
    main:
            abricate_db = ['ncbi', 'card', 'vfdb', 'ecoh', 'argannot', 'plasmidfinder', 'resfinder']
            abricate(fasta_input, abricate_db)  //start process abricate with according variables
            abricate_output_ch = abricate.out.abricate_output_ch    //assign main-output of abricate-process to channel
}