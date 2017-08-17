#!/bin/bash

# $1 - accepts a list of genes (split list of genes into lines and process each separately)
# $2 - outfile

maleList="/home/ccurnin/cnv/cnvkit/categories/male.txt"

function write_stats() {

        out="/home/ccurnin/cnv/cnvkit/freqTable.csv"

        declare -a gains=("${!2}")
        declare -a losses=("${!3}")
        declare -a female_y=("${!4}")

        gain_freq=$(bc <<< "scale=10; ${#gains[@]} / $5")
        loss_freq=$(bc <<< "scale=10; ${#losses[@]} / $5")
        female_y_freq=$(bc <<< "scale=10; ${#female_y[@]} / $6")

	gain_mean=$(echo ${gains[@]} | awk '{
	    for (i = 1;i <= NF; i++) {
        	sum += $i
	    };
	    print sum / NF
	}')

	loss_mean=$(echo ${losses[@]} | awk '{
            for (i = 1;i <= NF; i++) {
                sum += $i
            };
            print sum / NF
        }')

	gain_stdev=$(echo ${gains[@]} | awk -vM=$gain_mean '{
    	for (i = 1; i <= NF; i++) {
        	sum += ($i-M) * ($i-M)
	    };
	    print sqrt (sum / NF)
	}')

	loss_stdev=$(echo ${losses[@]} | awk -vM=$loss_mean '{
        for (i = 1; i <= NF; i++) {
                sum += ($i-M) * ($i-M)
            };
            print sqrt (sum / NF)
        }')

	echo "gene ${1}"
        
	mapfile -t gains_sorted < <(for num in "${gains[@]}"; do echo "$num"; done | sort -n)
	mapfile -t losses_sorted < <(for num in "${losses[@]}"; do echo "$num"; done | sort -n)

	echo "gene ${1}"

	gains_length=${#gains_sorted[@]}
	if (( gains_length % 2 == 1)) 
	then
		gain_median="${gains_sorted[ $((gains_length / 2)) ]}"
	else
		gain_median="$(bc <<< "scale=10; ( ${gains_sorted[ $((gains_length/2)) ]} + ${gains_sorted[ $((gains_length/2-1)) ]} ) / 2")"
	fi
	
	echo "gene ${1}"

	losses_length=${#losses_sorted[@]}
        if (( losses_length % 2 == 1))
        then
                loss_median="${losses_sorted[ $((losses_length / 2)) ]}"
        else
                loss_median="$(bc <<< "scale=10; ( ${losses_sorted[ $((losses_length/2)) ]} + ${losses_sorted[ $((losses_length/2-1))]} ) / 2")"
        fi
	

        echo "counter ${5}"
        echo "female_counter ${6}"

        echo "gains" 
	echo "gain freq: ${gain_freq}"
        echo "${gains[*]}"
	echo "${gains_sorted[*]}"
	echo "gain mean: ${gain_mean}"
	echo "gain median: ${gain_median}"
	echo "gain stdev: ${gain_stdev}"
	
        echo "losses"
	echo "loss freq: ${loss_freq}"
        echo "${losses[*]}"
	echo "${losses_sorted[*]}"
	echo "loss mean: ${loss_mean}"
	echo "loss median: ${loss_median}"
	echo "loss stdev: ${loss_stdev}"

        echo "female_y"
        echo "${female_y[*]}"
	echo "female y freq: ${female_y_freq}"

	echo "$gene","$gain_freq","$gain_mean","$gain_median","$gain_stdev","$loss_freq","$loss_mean","$loss_median","$loss_stdev","$female_y_freq" > "$7"
}


while read gene
do

	echo "$gene"

	gains=()
	losses=()
	female_y=()

	counter=0
	female_counter=0

	for callFile in /oak/stanford/groups/euan/cnvkit/WEScallCNS/* /oak/stanford/groups/euan/cnvkit/WGScallCNS/*
	do	
		UDN_ID=$(sed "s|\..*||" <<< "$(basename $callFile)")
		counter=$((counter+1))
	
		echo "$UDN_ID"

		#get sample gender
                isMale=`fgrep -c "$UDN_ID" "$maleList"` #if [ $isMale -eq 0 ] then echo female else scho male fi

		if [ $isMale -eq 0 ] 
		then 
			female_counter=$((female_counter+1))
		fi

		#get number of lines (segments) gene is a part of
		matches=$(grep -P "(\t|,)"$gene"(\t|,)" "$callFile" | wc -l)

		sampleCN=0
		chrom=""
		#search for gene in file
		while read -r line #TOD0: exit if no match is found
		do
			cn=$(awk '{print $6}' <<< "$line")
			sampleCN=$((sampleCN+cn))

			chrom=$(awk '{print $1}' <<< "$line")
		
		done < <(grep -P "(\t|,)"$gene"(\t|,)" "$callFile")
		

		sampleMeanCN=$(bc <<< "scale = 2; $sampleCN / $matches")

		if [ "$chrom" == "X" ] || [ "$chrom" == "Y" ]
		then
			if [ $isMale -ne 0 ] #male: ploidy is 1
			then
				echo "${UDN_ID} is male"
				if (( $(echo "$sampleMeanCN > 1" | bc -l) ))
                        	then    
                         		gains+=($sampleMeanCN)
                  		elif (( $(echo "$sampleMeanCN < 1" | bc -l) ))
				then
                         		losses+=($sampleMeanCN)
                 	 	fi

			elif [ "$chrom" == "X" ] #female: ploidy is 2
			then
 				if (( $(echo "$sampleMeanCN > 2" | bc -l ) ))
                                then
                                        gains+=($sampleMeanCN)
                                elif (( $(echo "$sampleMeanCN < 2" | bc -l) ))
				then
                                        losses+=($sampleMeanCN)
                                fi			
			
			else #false positives for elevated Y cn in females
				
				counter=$((counter-1)) #don't dilute gain/loss ratios by including females

				if (( $(echo "$sampleMeanCN > 0" | bc -l) ))
				then
					female_y+=($sampleMeanCN)
				fi
			fi
		else
			if (( $(echo "$sampleMeanCN > 2" | bc -l) ))
                        then
                                gains+=($sampleMeanCN)
                        elif (( $(echo "$sampleMeanCN < 2" | bc -l) ))
			then
                                losses+=($sampleMeanCN)
                       	fi
		fi
		
	done

	echo "writing..."
	write_stats $gene gains[@] losses[@] female_y[@] $counter $female_counter $2

done < $1
