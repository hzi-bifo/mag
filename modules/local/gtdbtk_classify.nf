process GTDBTK_CLASSIFY {
    tag "${meta.assembler}-${meta.binner}-${meta.id}"
    label 'highmemXLarge'

    conda "bioconda::gtdbtk=1.5.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gtdbtk:2.3.2--pyhdfd78af_0' :
        'biocontainers/gtdbtk:2.3.2--pyhdfd78af_0' }"

    input:
    tuple val(meta), path("bins/*")
    tuple val(db_name), path("database/*")

    output:
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.summary.tsv"        , emit: summary
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.classify.tree.gz"   , emit: tree, optional: true
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.markers_summary.tsv", emit: markers, optional: true
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.msa.fasta.gz"       , emit: msa, optional: true
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.user_msa.fasta"     , emit: user_msa, optional: true
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.*.filtered.tsv"       , emit: filtered, optional: true
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.log"                  , emit: log
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.warnings.log"         , emit: warnings
    path "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.failed_genomes.tsv"   , emit: failed, optional: true
    path "versions.yml"                                                            , emit: versions

    script:
    def args = task.ext.args ?: ''
    def pplacer_scratch = params.gtdbtk_pplacer_scratch ? "--scratch_dir pplacer_tmp" : ""
    """
    export GTDBTK_DATA_PATH="\${PWD}/database"
    if [ ${pplacer_scratch} != "" ] ; then
        mkdir pplacer_tmp
    fi

    gtdbtk classify_wf $args \
                    --genome_dir bins \
                    --prefix "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}" \
                    --out_dir "\${PWD}" \
                    --cpus ${task.cpus} \
                    --skip_ani_screen \
                    --pplacer_cpus ${params.gtdbtk_pplacer_cpus} \
                    ${pplacer_scratch} \
                    --min_perc_aa ${params.gtdbtk_min_perc_aa} \
                    --min_af ${params.gtdbtk_min_af}

    find -name "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}".*.classify.tree" | xargs -r gzip # do not fail if .tree is missing
    find -name "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}".*.msa.fasta" | xargs -r gzip 
    mv gtdbtk.log "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.log"
    mv gtdbtk.warnings.log "gtdbtk.${meta.assembler}-${meta.binner}-${meta.id}.warnings.log"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gtdbtk: \$(gtdbtk --version | sed -n 1p | sed "s/gtdbtk: version //; s/ Copyright.*//")
    END_VERSIONS
    """
}
