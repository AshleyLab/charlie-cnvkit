#!/bin/bash

# $1 - directory of input .cns files
# $2 - directory for output .call.cns files

cnvkit="/home/ccurnin/custom-cnvkit/cnvkit.py"

for CNSPath in ${1}/*
do	

	CNSName=$(basename "$CNSPath")
	UDN_ID=$(sed "s|\..*||" <<< "$CNSName")

	callCNSName="${UDN_ID}.call.cns"
	callCNSPath="${2}${callCNSName}"

	executable="/home/ccurnin/cnv/cnvkit/slurm/call${UDN_ID}.sh"
	
	echo "#!/bin/bash" > "$executable"

	#check if sample is male
	maleList="/home/ccurnin/cnv/cnvkit/categories/male.txt"
	femaleList="/home/ccurnin/cnv/cnvkit/categories/female.txt"

	if grep -xq "$UDN_ID" "$maleList"
	then

		echo "${cnvkit} call ${CNSPath} -x male -y -o ${callCNSPath}" >> "$executable"
		sbatch -p owners "$executable"

	elif grep -xq "$UDN_ID" "$femaleList"
	then

		echo "${cnvkit} call ${CNSPath} -x female -o ${callCNSPath}" >> "$executable"
        	sbatch -p owners "$executable"

	else
		echo "could not determine gender: ${UDN_ID}"
	fi 

done
