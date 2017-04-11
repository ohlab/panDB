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


	
