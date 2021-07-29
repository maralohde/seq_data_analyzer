#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// params.input = true --> wenn input = true wird channel ausgeführt

if (params.input == true) { exit 1, "Please provide an fastq file via [--input]" }

/************************** 
* INPUTs
**************************/

if (params.input)
{
    println "This is your input: "
    input_data_ch = Channel
    .fromPath(params.input, checkIfExists: true)
    .map {file -> tuple(file.baseName, file)} //Filename 
    .view() //show Input structure
}
else 
{
    println "Please provide an input!"
}
    
println "This is the input: " + params.input + "!" 

/************************** 
* Workflows
**************************/

include { taxonomy_classification_wf } from './workflows/taxonomy_classification.nf'


/************************** 
* MAIN WORKFLOW
**************************/

workflow {
    if (params.input){ //wenn es einen Input gibt, führe diesen wf aus
        taxonomy_classification_wf(input_data_ch) //workflow(input)
    }
}