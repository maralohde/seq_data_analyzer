process minimap2 {
  label 'minimap2'
    input:
      tuple val(name), path(reads), path(fastas)
    output:
      tuple val(name), path("ont_sorted.bam")
    shell:
    """
    minimap2 -ax map-ont ${fastas} ${reads} | samtools view -bS - | samtools sort -@ ${task.cpus} - > ont_sorted.bam
    """
}


