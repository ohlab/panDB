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


source env_var.sh

cd "$panDB_dir"

#--------------1. download data-----------------

quote=\'
sed -i "s/$quote/_/g" "assembly_summary.bacteria.txt"
sed -i "s/\"/_/g" "assembly_summary.bacteria.txt"

#==============Test using 3 Ecoli genomes=============
cat "assembly_summary.bacteria.txt" | awk -F '\t' '{if($1=="GCA_001283585.1") print $0}' > assembly_summary.bacteria.test.txt 
cat "assembly_summary.bacteria.txt" | awk -F '\t' '{if($1=="GCA_002544095.1") print $0}' >> assembly_summary.bacteria.test.txt 
cat "assembly_summary.bacteria.txt" | awk -F '\t' '{if($1=="GCA_000471385.1") print $0}' >> assembly_summary.bacteria.test.txt 
#=====================================================

mkdir "library_test_bacteria"
cat "assembly_summary.bacteria.test.txt" | xargs -I {} ./scripts/download_fna.sh bacteria {}
mkdir genome_all_v2

#--------------2. generate representative list---------------

cat "assembly_summary.bacteria.test.txt" | grep -F "representative genome" | awk -F '\t' '{print $7 "\t" $1}' > "bacteria.repr.list"

#--------------3. prepare qsub jobs-----------------

cd scripts
"$panDB_dir"/scripts/job_alloc.sh bacteria 1 "walltime=2:00:00,mem=8gb,nodes=1:ppn=1"
cd ..

#--------------4. run jobs on local-----------------

for qsub in "$panDB_dir"/"library_test_bacteria"/qsub_jobs/*.qsub; do
	chmod +x "$qsub"
	"$qsub"
done

#==============Check results===================

if cmp -s "$panDB_dir"/assembly_summary.bacteria.test.txt "$panDB_dir"/test/assembly_summary.bacteria.test.txt ; then
   echo "Assembly summary file checked" > test_result
else
   echo "Assembly summary file format changed" > test_result
fi

if cmp -s "$panDB_dir"/bacteria.repr.list "$panDB_dir"/test/bacteria.repr.list ; then
   echo "Repr list extraction checked" >> test_result
else
   echo "Repr list extraction not working properly" >> test_result
fi


   if cmp -s "$panDB_dir"/library_test_bacteria/562/GCA_000471385.1_E_coliM18-1.0_genomic.fna "$panDB_dir"/test/GCA_000471385.1_E_coliM18-1.0_genomic.fna ; then
	echo "GCA_000471385 genome unchanged" >> test_result
   else
	echo "GCA_000471385 genome changed" >> test_result
   fi

   if cmp -s "$panDB_dir"/library_test_bacteria/562/GCA_001283585.1_8205_3_77_genomic.fna "$panDB_dir"/test/GCA_001283585.1_8205_3_77_genomic.fna ; then
	echo "GCA_001283585 genome unchanged" >> test_result
   else
	echo "GCA_001283585 genome changed" >> test_result
   fi

   if cmp -s "$panDB_dir"/library_test_bacteria/562/GCA_002544095.1_ASM254409v1_genomic.fna "$panDB_dir"/test/GCA_002544095.1_ASM254409v1_genomic.fna ; then
	echo "GCA_002544095 genome unchanged" >> test_result
   else
	echo "GCA_002544095 genome changed" >> test_result
   fi


if cmp -s "$panDB_dir"/genome_all_v2/bacteria_562.fa "$panDB_dir"/test/bacteria_562.fa ; then
   echo "pan-genome extraction checked" >> test_result
else
   echo "pan-genome extraction not working properly" >> test_result
fi

rm -r genome_all_v2
rm -r library_test_bacteria
rm assembly_summary.bacteria.test.txt
