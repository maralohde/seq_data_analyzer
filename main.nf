#!/usr/bin/env nextflow
// params.input = true --> wenn input = true wird channel ausgeführt

// data import
if (params.input)
{
    println "This is your input: "
    input_data_ch = Channel
    .fromPath(params.input)
    .map {file -> tuple(file.baseName, file)} //Filename 
    .view()
}
else 
{
    println "Please define an input!"
}
    
// process to unzip the fastq.gz files from input
process unzipFiles {
    publishDir "${params.output}/unzipped_files", mode: 'copy', pattern: "*.fastq"
    input:
        tuple val(name), path(fastq_reads) from input_data_ch
    output:
        tuple val(name), path("*.fastq") into unzipped_files
    script:
    """
    zcat ${fastq_reads} > ${name}
    """
}

//println "This is the input: " + params.example + "!" 

// taxonomic classification
process sourmash_signatures {
    publishDir "${params.output}/sourmash_signatures", mode:'copy', pattern: "*.fastq.sig"
    input:
        tuple val(name), path(fastq_reads) from unzipped_files
    output:
        tuple val(name), path("*.fastq.sig") into sourmash_signatures
    script:
    """
    sourmash sketch dna -p scaled=1000,k=31 --name-from-first *.fastq
    """
}