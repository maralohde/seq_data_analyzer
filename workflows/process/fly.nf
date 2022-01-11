process flye {
    label 'flye'  
  input:
    tuple val(name), path(read)
  output:
    tuple val(name), path(read), path("${name}.fasta")
  script:
    """
    flye --plasmids --meta -t ${task.cpus} --nano-raw ${read} -o assembly --min-overlap ${params.overlap}
    mv assembly/assembly.fasta ${name}.fasta 
    """
  }

