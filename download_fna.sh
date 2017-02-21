#!/bin/bash


#=========args=========
# $1=kingdom
# $2=line from summary
#======================

source env_var.sh

cd "$panDB_dir"

#-----1. parsing from summary file-----

species_taxid=$(echo "$2" | awk -F '\t' '{print $7}')
ftp_path=$(echo "$2" | awk -F '\t' '{print $20}')
base_name=$(echo "$ftp_path" | awk -F '/' '{print $10}')
fullpath=$(echo "$ftp_path""/""$base_name""_genomic.fna.gz")
echo -e "$species_taxid\t$base_name"

#-----2. download genome-----

cd "library_test_$1"

if [ ! -d "$species_taxid" ]; then
	mkdir "$species_taxid"
fi
cd "$species_taxid"
	
wget "$fullpath" 

#-----3. unzip and add to namelist-----

gunzip "$base_name""_genomic.fna.gz"
echo "$base_name""_genomic.fna" >> list.txt

cd ..
cd ..


	
