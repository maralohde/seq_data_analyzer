#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// params.input = true --> wenn input = true wird channel ausgeführt

if (params.fastq == true) { exit 1, "Please provide an fastq file via [--input]" }
if (params.fasta == true) { exit 1, "Please provide an fasta file via [--input]" }

/************************** 
* INPUTs
**************************/

if (params.fastq)
{
    println "This is your input: "
    fastq_input_ch = Channel
    .fromPath(params.fastq, checkIfExists: true)
    .map {file -> tuple(file.baseName, file)} //Filename 
    .view() //show Input structure
}
else 
{
    println "Please provide an input!"
}
    
println "This is the input: " + params.fastq + "!" 

/************************** 
* Workflows
**************************/

include { taxonomy_classification_wf } from './workflows/taxonomy_classification.nf'


/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    if (params.fastq){ //wenn es einen Input gibt, führe diesen wf aus
        taxonomy_classification_wf(fastq_input_ch) //workflow(input)
    }
}