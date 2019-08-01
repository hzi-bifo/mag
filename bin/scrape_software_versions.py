#!/usr/bin/env python
from __future__ import print_function
from collections import OrderedDict
import re

regexes = {
    'nf-core/mag': ['v_pipeline.txt', r"(\S+)"],
    'Nextflow': ['v_nextflow.txt', r"(\S+)"],
    'MultiQC': ['v_multiqc.txt', r"multiqc, version (\S+)"],
    'fastqc': ['v_fastqc.txt', r"FastQC v(\S+)"],
    'fastp': ['v_fastp.txt', r"fastp (\S+)"],
    'megahit': ['v_megahit.txt', r"MEGAHIT v(\S+)"],
    'metabat': ['v_metabat.txt', r"version (\S+)"],
    'NanoPlot': ['v_nanoplot.txt', r"NanoPlot (\S+)"],
    'Filtlong': ['v_filtlong.txt', r"Filtlong v(\S+)"],
    'porechop': ['v_porechop.txt', r"(\S+)"],
    'NanoLyse': ['v_nanolyse.txt', r"NanoLyse (\S+)"],
    'SPAdes': ['v_spades.txt', r"SPAdes v(\S+)"],
    'BUSCO': ['v_busco.txt', r"BUSCO (\S+)"],
    'centrifuge': ['v_centrifuge.txt', r"centrifuge-class version (\S+)"],
    'Kraken2': ['v_kraken2.txt', r"Kraken version (\S+)-beta"],
    'Quast': ['v_quast.txt', r"QUAST v(\S+)"],
    'CAT': ['v_cat.txt', r"CAT v(\S+)"]
}
results = OrderedDict()
results['nf-core/mag'] = '<span style="color:#999999;\">N/A</span>'
results['Nextflow'] = '<span style="color:#999999;\">N/A</span>'
results['MultiQC'] = '<span style="color:#999999;\">N/A</span>'
results['fastqc'] = '<span style="color:#999999;\">N/A</span>'
results['fastp'] = '<span style="color:#999999;\">N/A</span>'
results['megahit'] = '<span style="color:#999999;\">N/A</span>'
results['metabat'] = '<span style="color:#999999;\">N/A</span>'
results['NanoPlot'] = '<span style="color:#999999;\">N/A</span>'
results['Filtlong'] = '<span style="color:#999999;\">N/A</span>'
results['porechop'] = '<span style="color:#999999;\">N/A</span>'
results['NanoLyse'] = '<span style="color:#999999;\">N/A</span>'
results['SPAdes'] = '<span style="color:#999999;\">N/A</span>'
results['BUSCO'] = '<span style="color:#999999;\">N/A</span>'
results['centrifuge'] = '<span style="color:#999999;\">N/A</span>'
results['Kraken2'] = '<span style="color:#999999;\">N/A</span>'
results['CAT'] = '<span style="color:#999999;\">N/A</span>'
results['Quast'] = '<span style="color:#999999;\">N/A</span>'

# Search each file using its regex
for k, v in regexes.items():
    with open(v[0]) as x:
        versions = x.read()
        match = re.search(v[1], versions)
        if match:
            results[k] = "v{}".format(match.group(1))

# Remove software set to false in results
for k in results:
    if not results[k]:
        del(results[k])

# Dump to YAML
print('''
id: 'software_versions'
section_name: 'nf-core/mag Software Versions'
section_href: 'https://github.com/nf-core/mag'
plot_type: 'html'
description: 'are collected at run time from the software output.'
data: |
    <dl class="dl-horizontal">
''')
for k, v in results.items():
    print("        <dt>{}</dt><dd><samp>{}</samp></dd>".format(k, v))
print("    </dl>")

# Write out regexes as csv file:
with open('software_versions.csv', 'w') as f:
    for k, v in results.items():
        f.write("{}\t{}\n".format(k, v))
