#!/bin/bash

#=========args=========
# $1=kingdom
# $2=taxid
#======================


source env_var.sh

cd "$panDB_dir"/"library_test_$1"


	d=$2
	cd "$d"

	#----0. copy all sequences to work on----

	rm -r repr_gen
	mkdir repr_gen
	cp *.fna repr_gen
	cd repr_gen	

	#----1. check if >1 genomes----

	ng=$(ls *.fna | wc -l)
	if (( ng > 1 )); then

		#----2. determine the starting representative sequence, rseq----

		# taxID=$(echo ${d::${#d}-1})
		taxID=$(echo "$d")
		rbase=$(cat "$panDB_dir"/"$1.repr.list" | awk -v tid=$taxID -F '\t' '{ if ($1==tid) print $2}' | head -n 1 | awk -F '.' '{print $1}')
		if [[ ! -z $rbase ]]; then
			rseq=$(ls | grep "$rbase")
		else
			rseq=$(ls -S | head -n 1)
		fi
		
		hdcnt=0
		while read line; do
			echo $line | sed "/^>/ s/.*/>representative_$hdcnt/g" >> representative.fasta
			((hdcnt++))
		done < "$rseq"
		rm "$rseq"

		#----3. iteration----
		#----3.0 determine the number of cycles----

		nc=$(( ng - 1 ))
		if (( ng > 51 )); then nc=50; fi

		for((cnt=1;cnt<=nc;cnt++)); do		
		
			#----3.1 largest genome as query----
		
			qseq=$(ls -S *.fna | head -n 1)

			hdcnt=0
			while read line; do
				echo $line | sed "/^>/ s/.*/>query_$hdcnt/g" >> query.fasta
				((hdcnt++))
			done < "$qseq"
			rm "$qseq"
		
			#----3.2 run mugsy----
			
			mkdir mugsy
			source "$mugsy_dir"/mugsyenv.sh
			"$mugsy_dir"/mugsy --directory "$panDB_dir"/"library_test_$1"/"$d"/repr_gen/mugsy --prefix alignment representative.fasta query.fasta

			#----3.3 run repr extracter----
			cd mugsy
			cp "$panDB_dir"/scripts/repr_extracter_0 ./repr_extracter
			./repr_extracter $cnt

			mv qblocks.fasta ../qblocks.fasta
			cd ..
			rm -r mugsy			
			
			#----combine representative and extracter output----
			cat representative.fasta qblocks.fasta > representative.new.fasta
			mv representative.new.fasta representative.fasta
			rm qblocks.fasta
			rm query.fasta
		done
		
	else 
		#----only one genome, this is the representative sequence----
		
		mv *.fna representative.fasta 
		hdcnt=0
		while read line; do
			echo $line | sed "/^>/ s/.*/>representative_$hdcnt/g" >> representative.new.fasta
			((hdcnt++))
		done < representative.fasta 
		mv representative.new.fasta representative.fasta
	fi

	mv "representative.fasta" "$panDB_dir"/genome_all_v2/"$1_$d.fa"

	cd ..
	rm -r repr_gen


