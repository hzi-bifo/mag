process METAWRAP {
    label 'process_medium'

    conda "bioconda::metawrap-mg"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/metawrap-mg:1.3.0--hdfd78af_1' :
        'quay.io/biocontainers/metawrap-mg' }"

    input:
    path(bins)

    output:
    path("metawrap_*_bins/*.fa")		, optional: true, emit: refined_bins
    path("metawrap_*_bins.stats")		, optional: true, emit: refined_bins_stats
    path("metawrap_*_bins.contigs")		, optional: true, emit: refined_bins_contigs
    path("*_bins.stats")			, optional: true, emit: stats
    path("*_bins.contigs")			, optional: true, emit: contigs
    path("*_bins/*.fa")				, optional: true, emit: bins
    path("figures/*.png")			, optional: true, emit: figures
    path("work_files/*")			, optional: true, emit: work_files
    path "versions.yml"						, emit: versions

   when:
   task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def completion =  params.completion ?: 50
    def contamination = params.contamination ?: 10 
    """
    #!/bin/bash
    # Paths to custom pipelines and scripts of metaWRAP
    mw_path=\$(which metawrap)
    bin_path=\${mw_path%/*}
    SOFT=\${bin_path}/metawrap-scripts
    PIPES=\${bin_path}/metawrap-modules
    # Storing all bins directories paths into an array bins_directories 
    bins_directories=( \$(find ${params.outdir}/GenomeBinning/ -maxdepth 2 -type d -name "*_bins") ) 
    # Decompress all bins fasta file for MetaWRAP bin_refinement script 
    find "\${bins_directories[@]}" -name "*.fa.gz" -exec gunzip -q -f {} +
    # Assign each path for MetaWRAP bin_refinement script     
    binsA="\${bins_directories[0]}"
    binsB="\${bins_directories[1]}"  
    binsC="\${bins_directories[2]}"
    # Running MetaWRAP bin_refinement script
    \${mw_path} bin_refinement \\
        $args \\
        -t 96 \\
        -A "\${binsA}" \\
        -B "\${binsB}" \\
        -C "\${binsC}" \\
        -c ${params.completion} \\
        -x ${params.contamination}\\
        -o ${params.outdir}/GenomeBinning/MetaWRAP_Refiner/
    # Compress all bins fasta files as a best practice 
    find "\${bins_directories[@]}" -name "*.fa" -exec gzip {} +

    metawrap_version=\$(metawrap --version | awk '{print \$2}')
    cat <<-END_VERSIONS > versions.yml
        metaWRAP v=1.3.2
    END_VERSIONS
    """
}
