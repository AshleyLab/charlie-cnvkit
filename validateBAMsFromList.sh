#!/bin/bash
#validates all BAMs for samples given by list of UDN_IDs

samples="/scratch/PI/euan/common/udn/gateway/data/"
validator="/share/PI/euan/apps/bcbio/anaconda/bin/bam validate"

while read UDN_ID 
do
	
	caseDirectory="$samples""$UDN_ID"

	find $caseDirectory -name "*.bam"| while read pathToBAM
	do 

        	BAM=$(basename $pathToBAM)
        	output="/home/ccurnin/cnv/cnvkit/BAMValidationResults/${BAM}.txt"

        	executable="/home/ccurnin/cnv/cnvkit/slurm/validate${BAM}.sh"

        	echo "$executable"
        
        	echo "#!/bin/bash" > "$executable"
        	echo "${validator} --disableStatistics --in ${pathToBAM} &> ${output}" >> "$executable"

        	sbatch -p owners "$executable"
	done

done < $1
