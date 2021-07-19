#!/usr/bin/env nextflow
// params.input = true --> wenn input = true wird channel ausgeführt

// data import
if (params.input)
{
    println "This is your input: "
    input_data_ch = Channel
    .fromPath(params.input)
    .map {file -> tuple(file.baseName, file)} //Filename 
    .view() //Input structure
}
else 
{
    println "Please define an input!"
}
    
// process to unzip the fastq.gz files from input
process unzipFiles {
    publishDir "${params.output}/unzipped_files", mode: 'copy', pattern: "*.fastq"
    input:
        tuple val(name), path(fastq_reads) from input_data_ch // Tabelle mit zwei Spalten name und fastq_reads
    output:
        tuple val(name), path("*.fastq") into unzipped_files
    script:
    """
    zcat ${fastq_reads} > ${name}
    """
}

//println "This is the input: " + params.example + "!" 

process download_db {
    publishDir "${params.output}/database", mode:'copy', pattern: "*.json.gz" 
    output:
        path("*.json.gz") into database
    """
    wget -O genbank-k31.lca.json.gz https://osf.io/4f8n3/download
    """
}

// build signatures from fastq files
process sourmash_signatures {
    publishDir "${params.output}/sourmash_signatures", mode:'copy', pattern: "*.fastq.sig"
    input:
        tuple val(name), path(fastq_reads) from unzipped_files
    output:
        tuple val(name), path("*.fastq.sig") into sourmash_signatures
    script:
    """
    sourmash sketch dna -p scaled=1000,k=31 --name-from-first ${fastq_reads}
    """
}
process sourmash_classification {
    publishDir "${params.output}/sourmash_classification", mode: 'copy', pattern: "${name}_taxonomy.tsv"
    input:
        tuple val(name), path(signatures) from sourmash_signatures
        file query from database
    output: 
        tuple val(name), path("${name}_taxonomy.tsv") into sourmash_classification
    script:
    """
    sourmash lca classify \
        --db genbank-k31.lca.json.gz \
        --query ${signatures} \
        > ${name}_taxonomy.tsv
    
    """    
}