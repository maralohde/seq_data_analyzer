include { flye } from './process/flye.nf'

workflow assembly_wf {
    take: 
        fastq_pass_input  
    main:
        flye(fastq_pass_input)
} 