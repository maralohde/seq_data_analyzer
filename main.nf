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

// dir input
    if (params.fast5) 
    { 
        fast5_input_ch = Channel
        .fromPath(params.fast5, checkIfExists: true)
    //.filter(~"fasta")
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
}

/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    .    
\033[0;33mUsage examples:${c_reset}
    nextflow run replikation/poreCov --fastq '*.fasta.gz' -r 0.9.5 -profile local,singularity
${c_yellow}Inputs (choose one):${c_reset}
    --fast5         one fast5 dir of a nanopore run containing multiple samples (barcoded);
                    to skip demultiplexing (no barcodes) add the flag [--single]
                    ${c_dim}[Basecalling + Genome reconstruction + Lineage + Reports]${c_reset}
    --fastq         one fastq or fastq.gz file per sample or
                    multiple file-samples: --fastq 'sample_*.fastq.gz'
                    ${c_dim}[Genome reconstruction + Lineage + Reports]${c_reset}
    --fastq_pass    the fastq_pass dir from the (guppy) bascalling
                    --fastq_pass 'fastq_pass/'
                    to skip demultiplexing (no barcodes) add the flag [--single]
                    ${c_dim}[Genome reconstruction + Lineage + Reports]${c_reset}
    --fasta         direct input of genomes - supports multi-fasta file(s) - can be gzip compressed (.gz)
                    ${c_dim}[Lineage + Reports]${c_reset}
${c_yellow}Workflow control (optional)${c_reset}
    --update        Always try to use latest pangolin & nextclade release [default: $params.update]
    --samples       .csv input (header: Status,_id), renames barcodes (Status) by name (_id), e.g.:
                    Status,_id
                    barcode01,sample2011XY
                    BC02,thirdsample_run
    --extended      poreCov utilizes from --samples these additional headers:
                    Submitting_Lab,Isolation_Date,Seq_Reason,Sample_Type
    --nanopolish    use nanopolish instead of medaka for ARTIC (needs --fast5)
                    to skip basecalling use --fastq or --fastq_pass and provide a sequencing_summary.txt
                    e.g --nanopolish sequencing_summary.txt                 
${c_yellow}Parameters - Basecalling  (optional)${c_reset}
    --localguppy    use a native installation of guppy instead of a gpu-docker or gpu_singularity 
    --guppy_cpu     use cpus instead of gpus for basecalling
    --one_end       removes the recommended "--require_barcodes_both_ends" from guppy demultiplexing
                    try this if to many barcodes are unclassified (beware - results might not be trustworthy)
    --guppy_model   guppy basecalling model [default: ${params.guppy_model}]
                    e.g. "dna_r9.4.1_450bps_hac.cfg" or "dna_r9.4.1_450bps_sup.cfg"
${c_yellow}Parameters - SARS-CoV-2 genome reconstruction (optional)${c_reset}
    --primerV       Supported primer variants - choose one [default: ${params.primerV}]
                        ${c_dim}ARTIC:${c_reset} V1, V2, V3, V4, V4.1
                        ${c_dim}NEB:${c_reset} VarSkipV1a
                        ${c_dim}Other:${c_reset} V1200
    --rapid         use rapid-barcoding-kit [default: ${params.rapid}]
    --minLength     min length filter raw reads [default: 350 (primer-scheme: V1-4); 500 (primer-scheme: V1200)]
    --maxLength     max length filter raw reads [default: 700 (primer-scheme: V1-4); 1500 (primer-scheme: V1200)]
    --min_depth     nucleotides below min depth will be masked to "N" [default ${params.min_depth}]
    --medaka_model  medaka model for the artic workflow [default: ${params.medaka_model}]
                    e.g. "r941_min_hac_g507" or "r941_min_sup_g507"
${c_yellow}Parameters - Genome quality control  (optional)${c_reset}
    --reference_for_qc      reference FASTA for consensus qc (optional, wuhan is provided by default)
    --seq_threshold         global pairwise ACGT sequence identity threshold [default: ${params.seq_threshold}] 
    --n_threshold           consensus sequence N threshold [default: ${params.n_threshold}] 
${c_yellow}Options  (optional)${c_reset}
    --cores         amount of cores for a process (local use) [default: $params.cores]
    --max_cores     max amount of cores for poreCov to use (local use) [default: $params.max_cores]
    --memory        available memory [default: $params.memory]
    --output        name of the result folder [default: $params.output]
    --cachedir      defines the path where singularity images are cached
                    [default: $params.cachedir]
    --krakendb      provide a .tar.gz kraken database [default: auto downloads one]
${c_yellow}Execution/Engine profiles (choose executer and engine${c_reset}
    poreCov supports profiles to run via different ${c_green}Executers${c_reset} and ${c_blue}Engines${c_reset} 
    examples:
     -profile ${c_green}local${c_reset},${c_blue}docker${c_reset}
     -profile ${c_yellow}test_fastq${c_reset},${c_green}slurm${c_reset},${c_blue}singularity${c_reset}
      ${c_green}Executer${c_reset} (choose one):
       local
       slurm
      ${c_blue}Engines${c_reset} (choose one):
       docker
       singularity
      ${c_yellow}Input test data${c_reset} (choose one):
       test_fasta
       test_fastq
       test_fast5
    """.stripIndent()
}