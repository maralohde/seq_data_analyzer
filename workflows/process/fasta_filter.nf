process fasta_filter {
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path('*.fasta')
    script:
    """
    find -name ${fasta} '*.fasta' > ${name}.fasta
    find -name ${fasta} '*.fasta.gz' | zcat ${fasta} > ${name}.fasta
    """
}

//find ./ -type f ${fasta} \( -iname \*.fasta -o -iname \*.fasta.gz \)> ${name}

// find -name ${fasta} '*.fasta' -exec cat {} > ${name}.fasta
// find -L ${fasta} -name '*.fasta.gz' -exec cat {} + | zcat >> ${name}.fasta
