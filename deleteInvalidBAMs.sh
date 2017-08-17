#!/bin/bash

validationResults="/home/ccurnin/cnv/cnvkit/BAMValidationResults/*"
udn="/scratch/PI/euan/common/udn"
metadata="/home/ccurnin/metadata/finalMetadata.csv"

for validationResult in $validationResults
do

	success=$(grep -ci "success" "$validationResult") #-i: case-insensitive; -c gives number of matches (though doubtful ever would be more than one)

	if (( "$success" >= 1 ))
	then
		
		
		echo "${validationResult} is valid"
		
	else 
		base=$(basename $validationResult)     
                BAM=${base%.*}

		echo "${BAM} is invalid"

		BAI=$(sed "s|bam|bai|" <<< "$BAM")
	        echo "removing ${BAI}"
                $(find "$udn" -name "$BAI" -delete)

         	count=$(find "$udn" -name "$BAM" | wc -l)
		if (( $count == 1 ))
        	then
                       	echo "removing ${BAM}"
                 	$(find "$udn" -name "$BAM" -delete)
        	elif  (( $count == 0 ))  
               	then
                       	echo "couldn't find ${BAM}: already deleted?"
                else 
                        echo "multiple files named ${BAM}"
		fi

	fi

done	
