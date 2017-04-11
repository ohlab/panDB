#!/bin/bash

#   PanDB compilation pipeline
#   Copyright (C) 2017 Wei Zhou

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
