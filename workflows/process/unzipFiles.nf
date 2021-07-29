Process unzipFiles {
    input:
        tuple val(name), path(fastq_reads) // Tabelle mit zwei Spalten name und fastq_reads
    output:
        tuple val(name), path("*.fastq")
    script:
    """
    zcat ${fastq_reads} > ${name}
    """
}
