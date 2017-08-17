#!/bin/bash

# $1 - list of UDN_IDs to include that are known to exist at $udnPath with at least one BAM
# $2 - directory to put coverage files
# $3 - target bed file
# $4 - antitarget bed file

#optional flags
# --WGS (without it, sample is assumed WES and antitarget coverage will be calculated)

udnPath="/scratch/PI/euan/common/udn/gateway/data/"
cnvkit="/share/PI/euan/apps/bcbio/anaconda/bin/cnvkit.py"

echo "$1"
echo "$2"
echo "$3" 
echo "$4"

while read sampleID
do			
	fullPath="${udnPath}${sampleID}"

	BAMPath=$(ls "$fullPath"/*.bam -S | head -1) #if the sample has multiple BAMs, take the largest one
	BAM=$(basename "$BAMPath")
	echo "$BAM"

	executable="/home/ccurnin/cnv/cnvkit/slurm/coverage${BAM}.sh"
	echo "$executable"
	
	echo "#!/bin/bash" > "$executable"
	
	targetOutput="${2}target/${sampleID}.targetcoverage.cnn"
	echo "${cnvkit} coverage ${BAMPath} ${3} -o ${targetOutput}" >> "$executable"

	if [[ $* != *--WGS* ]] #if WES, calculate antitarget coverage
	then
		antitargetOutput="${2}antitarget/${sampleID}.antitargetcoverage.cnn"
        	echo "${cnvkit} coverage ${BAMPath} ${4} -o ${antitargetOutput}" >> "$executable"
	fi
	
	sbatch -p owners --time 24:00:00 "$executable"

done < $1

