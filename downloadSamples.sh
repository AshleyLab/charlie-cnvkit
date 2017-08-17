#!/bin/bash

filesToDownload="/home/ccurnin/cnv/cnvkit/downloadSingles/*"
downloadScript="/home/ccurnin/labGit/udn2.0/new_download_udn_data.py"

for filePath in $filesToDownload
do
	file=$(basename $filePath)
	executable="/home/ccurnin/cnv/cnvkit/slurm/download${file}.sh"

	echo "$executable"
	echo "#!/bin/bash" > "$executable"
	echo "cat ${filePath}" >> "$executable"
	echo "python ${downloadScript} --bam --downloadSpecificUdnIDList ${filePath}" >> "$executable"

	sbatch -p owners --time 12:00:00 "$executable"

done
