#!/bin/bash

WESSamples="/home/ccurnin/cnv/cnvkit/WES/samplesAvailable.txt"

while read UDN_ID
do
	echo -n $UDN_ID" "

	metadata=$(grep $UDN_ID ~/metadata/finalMetadata.csv)
	gender=$(awk -F "\"*,\"*" '{print $2}' <<< $metadata)

	if [ "$gender" == "Female" ] 
	then
		echo $UDN_ID >> femaleSamples.txt
	else 	
		echo $UDN_ID >> maleSamples.txt
	fi

done < $WESSamples
