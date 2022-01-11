process abricate {
    label 'abricate'
    publishDir "${params.output}/abricate/", mode: 'copy', pattern: '*.tsv'
    input:
        tuple val(name), path(dir)
        each abricate_db
    output:
        tuple val(name), path("*.tsv"), emit: abricate_output_ch
        tuple val(name), val(abricate_db), path("*.tsv"), emit: abricate_files_ch //secondary output-channel to activate publishDir & feed res-parser
    script:
        """
        abricate --nopath --quiet --mincov 80 --db ncbi >> "${name}"_abricate_ncbi.tsv
        abricate --nopath --quiet --mincov 80 --db card >> "${name}"_abricate_card.tsv
        abricate --nopath --quiet --mincov 80 --db vfdb >> "${name}"_abricate_vfdb.tsv
        abricate --nopath --quiet --mincov 80 --db ecoh >> "${name}"_abricate_ecoh.tsv
        abricate --nopath --quiet --mincov 80 --db plasmidfinder >> "${name}"_abricate_plasmidfinder.tsv
        abricate --nopath --quiet --mincov 80 --db resfinder >> "${name}"_abricate_resfinder.tsv
        """}