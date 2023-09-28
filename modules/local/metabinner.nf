OPENBLAS_NUM_THREADS=2 

singularity run pipelines/images/metabinner.sif python pipelines/mag/bin/gen_kmer.py outputs/Assembly/MEGAHIT/MEGAHIT-test_minigut.contigs.fa 1000 4


bash run_metabinner.sh -a ${contig_file} -o ${output_dir} -d ${coverage_profiles} -k ${kmer_profile} -p ${metabinner_path}


python Metabinner.py --contig_file input_path/marmgCAMI2_short_read_pooled_gold_standard_assembly_1000.fa \
--coverage_profiles input_path/coverage_new_f1000_sr.tsv \
--composition_profiles input_path/kmer_4_f1000.csv --output output_path/marine_gold_f1k_metabinner_result.tsv \
--log output_path/result.log --use_hmm --hmm_icm_path path_to_MetaBinner/hmm_data/hmm/ \
--pacbio_read_profiles input_path/coverage_new_f1000_pb.tsv --binscore 0.2