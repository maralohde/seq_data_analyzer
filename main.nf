#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/************************** 
* INPUTs
**************************/

if (params.fastq)
{
    fastq_input_ch = Channel
    .fromPath(params.fastq, checkIfExists: true)
    .map {file -> tuple(file.baseName, file)} //Filename
    println "This is your input: " + params.fastq
    // .view() //show input structure 
    
}

if (params.fasta)
{
    fasta_input_ch = Channel
    .fromPath(params.fasta, checkIfExists: true)
    //.filter(~"fasta")
    .map {file -> tuple(file.baseName, file)} //Filename
    println "This is your input: " + params.fasta 
    // .view() //show input structure
}    

/************************** 
* ERROR
**************************/
if (params.fastq == true) { exit 1, "Please provide an fastq file via [--fastq]" }
if (params.fasta == true) { exit 1, "Please provide an fasta file via [--fasta]" }

/************************** 
* Workflows
**************************/

include { taxonomy_classification_wf } from './workflows/taxonomy_classification.nf'
include { antibiotic_resistance_screening_wf} from './workflows/antibiotic_resistance_screening_wf'

/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    // Wenn es ein fastq input gibt, führe diesen wf aus
    if (params.fastq){
        taxonomy_classification_wf(fastq_input_ch) //workflow(input)
    }  

    //bei params.fasta führe diesen wf aus
    if (params.fasta){
        antibiotic_resistance_screening_wf(fasta_input_ch)
    }
}