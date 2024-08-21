process GTDBTK_DB_PREPARATION {
    tag "${database}"

    conda "conda-forge::sed=4.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    path(database)

    output:
    tuple val("${database.toString().replace(".tar.gz", "")}"), path("database/*")

    script:
    """
    ln -s /vol/data/databases/clowm/CLDB-018e12ef116275458ea149715133b0ec/018e12ef116c7f84a8a3360ccf11471f database 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tar: \$(tar --version 2>&1 | sed -n 1p | sed 's/tar (GNU tar) //')
    END_VERSIONS
    """
}
