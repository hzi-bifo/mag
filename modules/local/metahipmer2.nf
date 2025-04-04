process MHM2 {
    tag "$meta.id"
    label 'process_high'
    conda "bioconda::spades=3.15.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	 'file://./mhm2_singularity.sif' :
         //'file://./pipelines/images/mhm2.2.sif' :
         'docker.io/robegan21/mhm2:v2.2.0.0' }"
    //container "/homes/zldeng/projects/pipelines/images/mhm2.latest.sif"
    //containerOptions '--shm-size 16g'


    input:
    // tuple val(meta), path(reads)
    tuple val(meta), path(reads1), path(reads2)

    output:
    tuple val(meta), path("MHM2-${meta.id}_scaffolds.fasta"), emit: assembly
    path "MHM2-${meta.id}.log"                              , emit: log
    // path "MHM2-${meta.id}_contigs.fasta.gz"                 , emit: contigs_gz
    path "MHM2-${meta.id}_scaffolds.fasta.gz"               , emit: assembly_gz
    // path "MHM2-${meta.id}_graph.gfa.gz"                     , emit: graph
    path "versions.yml"                                , emit: versions

    script:
    def args = task.ext.args ?: ''
    maxmem = task.memory.toGiga()
    def input_cmd = meta.single_end ? "-u ${meta.id}_1.fastq" : "-p ${meta.id}_1.fastq ${meta.id}_2.fastq"
    if ( params.mhm2_fix_cpus == -1 || task.cpus == params.mhm2_fix_cpus )
        """
        gunzip -dc ${reads1} > ${meta.id}_1.fastq
        ${meta.single_end ? "" : "gunzip -dc ${reads2} > ${meta.id}_2.fastq"}
        # gunzip -dc ${reads2} > ${meta.id}_2.fastq
        # mhm2.py --procs ${task.cpus} --nodes 1 $args -p ${meta.id}_1.fastq ${meta.id}_2.fastq \
        #    -o ${meta.id}
        #mhm2.py --procs ${task.cpus} --nodes 1 $args $input_cmd -o ${meta.id}
        mhm2.py $args $input_cmd -o ${meta.id}
        # mv ${meta.id}/assembly_graph_with_scaffolds.gfa SPAdes-${meta.id}_graph.gfa
        mv ${meta.id}/final_assembly.fasta MHM2-${meta.id}_scaffolds.fasta
        mv ${meta.id}/mhm2.log MHM2-${meta.id}.log
        # gzip "MHM2-${meta.id}_contigs.fasta"
        # gzip "SPAdes-${meta.id}_graph.gfa"
        gzip -c "MHM2-${meta.id}_scaffolds.fasta" > "MHM2-${meta.id}_scaffolds.fasta.gz"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            MetaHipMer2: 2.2.0.0.151-gfd4a8d06-master
        END_VERSIONS
        """
    else
        error "ERROR: " //'--mhm2_fix_cpus' was specified, but not succesfully applied. Likely this is caused by changed process properties in a custom config file."
}
