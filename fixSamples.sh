#!/bin/bash

cnvkit="/home/ccurnin/custom-cnvkit/cnvkit.py"
udn="/oak/stanford/groups/euan/cnvkit/"

if [[ $* == *--WGS* ]]
then
		
	output="/oak/stanford/groups/euan/cnvkit/WGSCNR/"
	antitargetPath="/oak/stanford/groups/euan/cnvkit/empty.antitargetcoverage.cnn"

	if [[ $* = *--male* ]]
        then
		echo "male"
                list="/home/ccurnin/cnv/cnvkit/categories/male.txt"
                reference="/home/ccurnin/cnv/cnvkit/references/WGS/maleUnaffected.cnn"
        else
		echo "female"
                list="/home/ccurnin/cnv/cnvkit/categories/female.txt"
                reference="/home/ccurnin/cnv/cnvkit/references/WGS/femaleUnaffected.cnn"
        fi

        grep -f "$list" <(ls /oak/stanford/groups/euan/cnvkit/otherWGS/{un,}affected/target/* /oak/stanford/groups/euan/cnvkit/StanfordWGS/target/*) | while read -r targetPath
        do	

                targetName=$(basename "$targetPath")
                UDN_ID=$(sed "s|\..*||" <<< "$targetName")

                executable="/home/ccurnin/cnv/cnvkit/slurm/fix${UDN_ID}.sh"

                outputFile="${output}${UDN_ID}.cnr"

                echo "#!/bin/bash" > "$executable"

                if [[ $* == *--male* ]]
                then
                        echo "${cnvkit} fix ${targetPath} ${antitargetPath} ${reference} -o ${outputFile}" >> "$executable"
                else
                        echo "${cnvkit} fix ${targetPath} ${antitargetPath} ${reference} -o ${outputFile}" >> "$executable"
                fi

                echo "$executable"
                echo "$targetPath"
                echo "$antitargetPath"
                sbatch -p owners "$executable"

        done

else

	output="/oak/stanford/groups/euan/cnvkit/WESCNR/"

	if [[ $* = *--male* ]] 
	then
		list="/home/ccurnin/cnv/cnvkit/categories/male.txt"
		reference="/home/ccurnin/cnv/cnvkit/references/WES/maleUnaffected.cnn"
	else
		list="/home/ccurnin/cnv/cnvkit/categories/female.txt"
		reference="/home/ccurnin/cnv/cnvkit/references/WES/femaleUnaffected.cnn"
	fi

	grep -f "$list" <(ls /oak/stanford/groups/euan/cnvkit/otherWES/{un,}affected/target/* /oak/stanford/groups/euan/cnvkit/StanfordWES/target/*) | while read -r targetPath
	do
		
		targetName=$(basename "$targetPath")    
                UDN_ID=$(sed "s|\..*||" <<< "$targetName")
                
                antitargetName="${UDN_ID}.antitargetcoverage.cnn"
                antitargetPath=$(find "$udn" -name "$antitargetName")

		executable="/home/ccurnin/cnv/cnvkit/slurm/fix${UDN_ID}.sh"

		outputFile="${output}${UDN_ID}.cnr"

		echo "#!/bin/bash" > "$executable"
		
		if [[ $* == *--male* ]]
		then
			echo "${cnvkit} fix ${targetPath} ${antitargetPath} ${reference} -o ${outputFile}" >> "$executable"
		else
			echo "${cnvkit} fix ${targetPath} ${antitargetPath} ${reference} -o ${outputFile}" >> "$executable"
		fi
	
		echo "$executable"
		echo "$targetPath"
		echo "$antitargetPath"
		sbatch -p owners "$executable"
        
	done
fi 
