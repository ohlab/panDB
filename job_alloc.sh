#!/bin/bash

#=========args=============
# $1=kingdom
# $2=number of total jobs
# $3=resource string
#==========================

source env_var.sh

cd $panDB_dir/"library_test_$1"

#-----0. # species in total-----

rm -r qsub_jobs
ls -d */ > ttl_species.txt

#-----1. # jobs in total-----

nj=$2
mkdir qsub_jobs

for((i=0;i<nj;i++)); do
	echo "#PBS -l $3" > qsub_jobs/mugsy_"$i".qsub
	echo "#PBS -N mugsy_$i" >> qsub_jobs/mugsy_"$i".qsub
	echo "cd $panDB_dir/scripts" >> qsub_jobs/mugsy_"$i".qsub
done

#-----2. allocate species to jobs-----
cnt=0;

while read line; do
	taxID=$(echo ${line::${#line}-1})
	jobID=$((cnt%nj))
	echo "./Inti_mugsy.sh $1 $taxID" >> qsub_jobs/mugsy_"$jobID".qsub
	((cnt++))
done < ttl_species.txt
