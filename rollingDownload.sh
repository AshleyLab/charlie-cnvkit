#!/bin/bash

#Slurm or Gateway seems unable to handle >25 concurrent downloads
#This script accepts an arbitrarily long list of IDs, dispatches 20 to be downloaded, and as the downloads finish, fires more so 20 are always downloading. 

downloadScript="/home/ccurnin/labGit/udn2.0/new_download_udn_data.py"
counter=1

rm /home/ccurnin/cnv/cnvkit/slurm/* 2> /dev/null

while true
do
	
	jobs=$(($(squeue -u $USER | grep XYZ | wc -l)-1)) #subtract one for header liner
	downloads=$(wc -l "$1" | sed "s|\(.*\) .*|\1|")
	
	echo "$downloads"

	if (("$counter" > "$downloads")) 
	then
		break
	fi

	if (("$jobs" >= 25))
	then
		sleep 2m
	else
		UDN_ID=$(sed "${counter}q;d" "$1")
		echo "now downloading ${UDN_ID}"
		
		UDN_IDFile="/home/ccurnin/cnv/cnvkit/slurm/${UDN_ID}.txt"
		echo "$UDN_ID" > "$UDN_IDFile"

		executable="/home/ccurnin/cnv/cnvkit/slurm/XYZ${UDN_ID}.sh"
		echo "#!/bin/bash" > "$executable"
		echo "echo ${UDN_ID}" >> "$executable"
        	echo "python ${downloadScript} --bam --downloadSpecificUdnIDList ${UDN_IDFile}" >> "$executable"

		sbatch -p owners,normal --time 24:00:00 "$executable"
		((counter++))

	fi
	
	echo "counter is ${counter}"
done
