#!/bin/bash

# $1 - output reference

#only uses unaffected samples

#optional flagseb
# --WGS (won't look for antitarget coverage files)
# --male (will produce male reference)

#parametrize for input file directory, gender, and output directory

cnvkit="/home/ccurnin/custom-cnvkit/cnvkit.py" #consults male.txt and female.txt to find samples' gender instead of trying to infer
fasta="/home/ccurnin/GRCh37.fa"

if [[ $* == *--WGS* ]]
then
	echo "WGS"

	if [[ $* == *--male* ]]
        then
                echo "making male"
                "$cnvkit" reference /oak/stanford/groups/euan/cnvkit/otherWGS/unaffected/target/* --fasta "$fasta" --male-reference -o "$1"
        else
                "$cnvkit" reference /oak/stanford/groups/euan/cnvkit/otherWGS/unaffected/target/* --fasta "$fasta" -o "$1"
        fi

else 
	echo "WES"	

	if [[ $* == *--male* ]]
	then
		echo "making male"
		"$cnvkit" reference /oak/stanford/groups/euan/cnvkit/otherWES/unaffected/{anti,}target/* --fasta "$fasta" --male-reference -o "$1"
	else
		"$cnvkit" reference /oak/stanford/groups/euan/cnvkit/otherWES/unaffected/{anti,}target/* --fasta "$fasta" -o "$1"
	fi
fi
