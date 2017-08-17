#!/bin/bash

# $1 - directory of input .cnr files
# $2 - directory for output .cns files

cnvkit="/home/ccurnin/custom-cnvkit/cnvkit.py"

for CNRPath in ${1}/*
do
	CNRName=$(basename "$CNRPath")
	UDN_ID=$(sed "s|\..*||" <<< "$CNRName")

	CNSName="${UDN_ID}.cns"
	CNSPath="${2}${CNSName}"

	executable="/home/ccurnin/cnv/cnvkit/slurm/segment${UDN_ID}.sh"
	
	echo "#!/bin/bash" > "$executable"
	echo "${cnvkit} segment ${CNRPath} -o ${CNSPath}" >> "$executable"

	sbatch -p owners "$executable"

done
