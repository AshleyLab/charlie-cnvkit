#!/bin/bash

#geneList="/oak/stanford/groups/euan/cnvkit/finalGeneList-short.txt"
outputDirectory="/oak/stanford/groups/euan/cnvkit/frequency/"
script="/home/ccurnin/cnv/cnvkit/buildFrequency.sh"

while read gene
do
	echo "firing ${gene}"	

	outputFile="${outputDirectory}${gene}.csv"

	executable="/home/ccurnin/cnv/cnvkit/slurm/frequency${gene}.sh"
	
	echo "#!/bin/bash" > "$executable"
	echo "$script <(echo "$gene") "$outputFile"" >> "$executable"

	sbatch -p owners "$executable"

done < $1

