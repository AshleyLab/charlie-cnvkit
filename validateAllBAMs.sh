#!/bin/bash

samples="/scratch/PI/euan/common/udn/gateway/data"
validator="/share/PI/euan/apps/bcbio/anaconda/bin/bam validate"

find $samples -name "*.bam"| while read pathToBAM
do 
	BAM=$(basename $pathToBAM)
	output="/home/ccurnin/cnv/cnvkit/BAMValidationResults/${BAM}.txt"

	executable="/home/ccurnin/cnv/cnvkit/slurm-submit/validate${BAM}.sh"

	echo "$executable"
	
	echo "#!/bin/bash" > "$executable"
	echo "${validator} --disableStatistics --in ${pathToBAM} &> ${output}" >> "$executable"

	sbatch -p owners "$executable"
done
