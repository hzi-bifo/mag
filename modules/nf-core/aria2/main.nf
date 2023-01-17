
process ARIA2 {
    tag "$source_url"
    label 'process_single'

    conda "conda-forge::aria2=1.36.0 conda-forge::tar"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/aria2:1.36.0' :
        'quay.io/biocontainers/aria2:1.36.0' }"

    input:
    val source_url

    output:
    path ("checkm_data_2015_01_16/"), emit: downloaded_file
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    downloaded_file = source_url.split("/")[-1]

    """
    set -e

    aria2c \\
        --check-certificate=false \\
        $args \\
        $source_url

    mkdir checkm_data_2015_01_16/
    tar x -C checkm_data_2015_01_16 -v -z -f *.tar.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        aria2: \$(echo \$(aria2c --version 2>&1) | grep 'aria2 version' | cut -f3 -d ' ')
    END_VERSIONS
    """
}
