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
    fastq_input_ch.view() //show input structure    
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

if (params.fastq_pass)
{
    fastq_pass_input_ch = Channel
    .fromPath(params.fastq_pass, checkIfExists: true)
    .map {file -> tuple(file.baseName, file)} //Filename
    println "This is your input: " + params.fasta 
    // .view() //show input structure
}  

// dir input
if (params.fast5) 
{ 
    fast5_input_ch = Channel
    .fromPath(params.fast5, checkIfExists: true)
    .map {file -> tuple(file.baseName, file)} //Filename
    println "This is your input: " + params.fast5
    }

/************************** 
* ERROR
**************************/
if (params.fastq == true) { exit 1, "Please provide an fastq file via [--fastq]" }
if (params.fasta == true) { exit 1, "Please provide an fasta file via [--fasta]" }
if (params.fasta == true) { exit 1, "Please provide an fasta file via [--fasta]" }

/************************** 
* Workflows
**************************/

include { taxonomy_classification_wf } from './workflows/taxonomy_classification.nf'
include { antibiotic_resistance_screening_wf} from './workflows/antibiotic_resistance_screening_wf'
include { basecalling_wf } from './workflows/basecalling.nf'
include {assembly_wf} from './workflows/assembly'

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

    //basecalling 

    if (params.fast5 && !params.fastq && !params.fastq_pass) {
            basecalling_wf(fast5_input_ch)
    }

    // Assembly of fastq_pass files
    if (params.fastq_pass) {
            assembly_wf(fastq_pass_input_ch)
    }
}

/************************** 
* HELP messages & checks
**************************/

// Log infos based on user inputs
if ( params.help ) { exit 0, helpMSG() }

// profile helps
if (params.profile) { exit 1, "--profile is WRONG use -profile" }

/*************  
* --help
*************/
if ( params.help ) { exit 0, helpMSG() }
if ( workflow.profile == 'standard' ) { exit 1, "NO EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }
if (workflow.profile.contains('local')) {
        println "\033[2m Using $params.cores/$params.max_cores CPU threads [--max_cores]\u001B[0m"
        println " "
    }

println " "
println "  If neccessary update via: nextflow pull maralohde/seq_data_analyzer"
println "________________________________________________________________________________"


if ( params.help ) { exit 0, helpMSG() }

def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """ 
\033[0;33mUsage examples:${c_reset}
    nextflow run maralohde/seq_data_analyzer --fastq '*.fasta.gz' -r 0.9.5 -profile local,singularity
${c_yellow}Inputs (choose one):${c_reset}
    --fast5         analyse from fast5 of a nanopore run
                    ${c_dim}[Basecalling + Assembly]${c_reset}   
    --fasta         direct genome input
                    ${c_dim}[antibiotic resistance detection via abricate]${c_reset}
                    detect antibiotic resitances with abricate
    --fastq         one fastq or fastq.gz file per sample or
                    multiple file-samples: --fastq 'sample_*.fastq.gz'
                    ${c_dim}[classification via sourmash]${c_reset}     
    --fastq_pass    not implemented yet
    --mixed         not implemented yet

${c_yellow}Parameters - Basecalling  (optional)${c_reset}
    --guppy_model   guppy basecalling model [default: ${params.guppy_model}]
                    e.g. "dna_r9.4.1_450bps_hac.cfg" or "dna_r9.4.1_450bps_sup.cfg"

${c_yellow}Engine profiles (choose executer and engine${c_reset})
     -profile ${c_green}local${c_reset},${c_blue}docker${c_reset}
    """.stripIndent()
}