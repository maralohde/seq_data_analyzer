process guppy_gpu {
    label 'guppy_gpu'
        container = 'nanozoo/guppy_gpu:5.0.7-1--ec2c6e7'
        containerOptions '--gpus all'
        publishDir "${params.output}/${params.readsdir}/", mode: 'copy', pattern: "*.fastq.gz"
    input:
        tuple val(name), path(dir)
    output:
        tuple val(name), path("*.fastq.gz"), emit: reads
        tuple val(name), path("fastq_tmp/*.txt"), emit: summary
    script:       
        """
        guppy_basecaller -c ${params.guppy_model} -i ${dir} -s fastq_tmp -x auto -r
        """
}