# nf-core/mag: Usage

## :warning: Please read this documentation on the nf-core website: [https://nf-co.re/mag/usage](https://nf-co.re/mag/usage)

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Input specifications

The input data can be passed to nf-core/mag in two possible ways using the `--input` parameter.

### Direct FASTQ input (short reads only)

The easiest way is to specify directly the path (with wildcards) to your input FASTQ files. For example:

```bash
--input 'path/to/data/sample_*_R{1,2}.fastq.gz'
```

This input method only works with short read data and will assign all files to the same group. By default, this group information is only used to compute co-abundances for the binning step, but not for group-wise co-assembly (see the parameter docs for [`--coassemble_group`](https://nf-co.re/mag/parameters#coassemble_group) and [`--binning_map_mode`](https://nf-co.re/mag/parameters#binning_map_mode) for more information about how this group information can be used).

Please note the following additional requirements:

- Files names must be unique
- Valid file extensions: `.fastq.gz`, `.fq.gz` (files must be compressed)
- The path must be enclosed in quotes
- The path must have at least one `*` wildcard character
- When using the pipeline with paired end data, the path must use `{1,2}` notation to specify read pairs
- To run single-end data you must additionally specify `--single_end`
- If left unspecified, a default pattern is used: `data/*{1,2}.fastq.gz`

### Samplesheet input file

Alternatively, to assign different groups or to include long reads for hybrid assembly with metaSPAdes, you can specify a CSV samplesheet input file that contains the paths to your FASTQ files and additional metadata.

This CSV file should contain the following columns:

`sample,group,short_reads_1,short_reads_2,long_reads`

The path to `long_reads` and `short_reads_2` is optional. Valid examples could look like the following:

```bash
sample,group,short_reads_1,short_reads_2,long_reads
sample1,0,data/sample1_R1.fastq.gz,data/sample1_R2.fastq.gz,data/sample1.fastq.gz
sample2,0,data/sample2_R1.fastq.gz,data/sample2_R2.fastq.gz,data/sample2.fastq.gz
sample3,1,data/sample3_R1.fastq.gz,data/sample3_R2.fastq.gz,
```

or

```bash
sample,group,short_reads_1,short_reads_2,long_reads
sample1,0,data/sample1.fastq.gz,,
sample2,0,data/sample2.fastq.gz,,
```

Please note the following requirements:

- 5 comma-seperated columns
- Valid file extension: `.csv`
- Must contain the header `sample,group,short_reads_1,short_reads_2,long_reads`
- Sample IDs must be unique
- FastQ files must be compressed (`.fastq.gz`, `.fq.gz`)
- `long_reads` can only be provided in combination with paired-end short read data
- Within one samplesheet either only single-end or only paired-end reads can be specified
- If single-end reads are specified, the command line parameter `--single_end` must be specified as well

Again, by default, the group information is only used to compute co-abundances for the binning step, but not for group-wise co-assembly (see the parameter docs for [`--coassemble_group`](https://nf-co.re/mag/parameters#coassemble_group) and [`--binning_map_mode`](https://nf-co.re/mag/parameters#binning_map_mode) for more information about how this group information can be used).

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/mag --input samplesheet.csv --outdir <OUTDIR> -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

See the [nf-core/mag website documentation](https://nf-co.re/mag/usage#usage) for more information about pipeline specific parameters.

### Reproducibility

It is a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/mag releases page](https://github.com/nf-core/mag/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

Additionally, to enable also reproducible results from the individual assembly tools this pipeline provides extra parameters. SPAdes is designed to be deterministic for a given number of threads. To generate reproducible results set the number of cpus with `--spades_fix_cpus` or `--spadeshybrid_fix_cpus`. This will overwrite the number of cpus specified in the `base.config` file and additionally ensure that it is not increased in case of retries for individual samples. MEGAHIT only generates reproducible results when run single-threaded.
You can fix this by using the prameter `--megahit_fix_cpu_1`. In both cases, do not specify the number of cpus for these processes in additional custom config files, this would result in an error.

MetaBAT2 is run by default with a fixed seed within this pipeline, thus producing reproducible results.

To allow also reproducible bin QC with BUSCO, run BUSCO providing already downloaded lineage datasets with `--busco_download_path` (BUSCO will be run using automated lineage selection in offline mode) or provide a specific lineage dataset via `--busco_reference` and use the parameter `--save_busco_reference`. This may be useful since BUSCO datasets are frequently updated and old versions do not always remain (easily) accessible.

For the taxonomic bin classification with [CAT](https://github.com/dutilh/CAT), when running the pipeline with `--cat_db_generate` the parameter `--save_cat_db` can be used to also save the generated database to allow reproducibility in future runs. Note that when specifying a pre-built database with `--cat_db`, currently the database can not be saved.

The taxonomic classification of bins with GTDB-Tk is not guaranteed to be reproducible, since the placement of bins in the reference tree is non-deterministic. However, the authors of the GTDB-Tk article examined the reproducibility on a set of 100 genomes across 50 trials and did not observe any difference (see [https://doi.org/10.1093/bioinformatics/btz848](https://doi.org/10.1093/bioinformatics/btz848)).


> **NB:** If you wish to periodically update individual tool-specific results (e.g. Pangolin) generated by the pipeline then you must ensure to keep the `work/` directory otherwise the `-resume` ability of the pipeline will be compromised and it will restart from scratch.

## A note on the ancient DNA subworkflow

nf-core/mag integrates an additional subworkflow to validate ancient DNA _de novo_ assembly:

[Characteristic patterns of ancient DNA (aDNA) damage](<(https://doi.org/10.1073/pnas.0704665104)>), namely DNA fragmentation and cytosine deamination (observed as C-to-T transitions) are typically used to authenticate aDNA sequences. By identifying assembled contigs carrying typical aDNA damages using [PyDamage](https://github.com/maxibor/pydamage), nf-core/mag can report and distinguish ancient contigs from contigs carrying no aDNA damage. Furthermore, to mitigate the effect of aDNA damage on contig sequence assembly, [freebayes](https://github.com/freebayes/freebayes) in combination with [BCFtools](https://github.com/samtools/bcftools) are used to (re)call the variants from the reads aligned to the contigs, and (re)generate contig consensus sequences.

## A note on bin refinement

### Error Reporting

DAS Tool may not always be able to refine bins due to insufficient recovery of enough single-copy genes. In these cases you will get a NOTE such as

```bash
[16/d330a6] NOTE: Process `NFCORE_MAG:MAG:BINNING_REFINEMENT:DASTOOL_DASTOOL (test_minigut_sample2)` terminated with an error exit status (1) -- Error is ignored
```

In this case, DAS Tool has not necessarily failed but was unable to complete the refinement. You will therefore not expect to find any output files in the `GenomeBinning/DASTool/` results directory for that particular sample.

If you are regularly getting such errors, you can try reducing the `--refine_bins_dastool_threshold` value, which will modify the scoring threshold defined in the [DAS Tool publication](https://www.nature.com/articles/s41564-018-0171-1).
