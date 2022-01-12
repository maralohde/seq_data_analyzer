process flye {
    label 'flye'  
    publishDir "${params.output}/${name}/flye/flye_unpolished", mode: 'copy', pattern: "assembly.fasta"
  input:
    tuple val(name), path(read)
  output:
    tuple val(name), path(read), path("${name}.fasta")
  script:
    """
    flye --plasmids --meta -t ${task.cpus} --nano-raw ${read} -o assembly
    mv assembly/assembly.fasta ${name}.fasta 
    """
  }
