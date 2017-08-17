#!/bin/bash

#1 - a list of UDN_IDs ALL of whose BAMs and BAIs will be deleted

udn="/scratch/PI/euan/common/udn/gateway/data/"

while read UDN_ID
do

	caseDirectory="${udn}${UDN_ID}"

	find "$caseDirectory" -maxdepth 1 -type f -name "*.bam*" -delete

done < $1
