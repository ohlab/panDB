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

#=========args=========
# $1=kingdom
# $2=number of PBS jobs
# $3=qsub resource string
#======================

source env_var.sh

cd "$panDB_dir"

#--------------1. download data-----------------

quote=\'
sed -i "s/$quote/_/g" "assembly_summary.$1.txt"
sed -i "s/\"/_/g" "assembly_summary.$1.txt"
mkdir "library_test_$1"
cat "assembly_summary.$1.txt" | xargs -I {} ./scripts/download_fna.sh $1 {}
mkdir genome_all_v2

#--------------2. generate representative list---------------

cat "assembly_summary.$1.txt" | grep -F "representative genome" | awk -F '\t' '{print $7 "\t" $1}' > "$1.repr.list"

#--------------3. prepare qsub jobs-----------------

cd scripts
./job_alloc.sh $1 $2 $3
cd ..

#--------------4. submit jobs-----------------

cd 
for qsub in "$panDB_dir"/"library_test_$1"/qsub_jobs/*.qsub; do
	qsub "$qsub"
done
