#!/bin/bash

#=========args==========================================================
# $1=bacteria name, genus and species separated by '_'
# $2=usearch e-value cut-off
# $3=usearch identity cut-off
# $4=minimum percent of marker gene sequence covered by the alignment
#=======================================================================


source env_var.sh

# extracting marker gene sequences, if they are not already extracted
if [ ! -f "$script_dir"/metaphlan_markers.fa ]; then
	"$bowtie2_dir"/bowtie2-inspect "$metaphlan_dir"/db_v20/mpa_v20_m200 > "$script_dir"/metaphlan_markers.fa
fi
if [ ! -f "$script_dir"/markers_info.txt ]; then
	bunzip2 -k "$metaphlan_dir"/utils/markers_info.txt.bz2 -c > "$script_dir"/markers_info.txt
fi

cat "$script_dir"/markers_info.txt | grep "|s__$1" | awk -F '\t' '{print $1}' > "$output_dir"/marker_subset.list
"$seqtk_dir"/seqtk subseq "$script_dir"/metaphlan_markers.fa "$output_dir"/marker_subset.list > "$output_dir"/marker_subset.fa

# mapping marker gene sequences to pan-genomes
database_path="$panDB_dir/genome_all_v2"
for fa in "$database_path"/*_*.fa; do
	base=$(echo $fa | awk -F '/' '{print $NF}')
	"$usearch_dir"/usearch -usearch_local "$output_dir"/marker_subset.fa -db $fa -id "$3" -evalue "$2" -userout "$output_dir"/$base.blast -strand both -maxaccepts 10 -userfields query+target+id+ql+tl+alnlen
done

# concat results
find "$output_dir" -type f -size 0 -delete
for blast_out in "$output_dir"/*.blast; do
	base=$(echo "$blast_out" | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}')
	while read line; do
		echo -e "$base\t$line" >> "$output_dir"/all_hits.txt
	done < "$blast_out"
done
cd "$output_dir"
ls *.blast | awk -F ".fa" '{print $1}' > contaminated_taxa.list
"$script_dir"/hit_analyses "$4"

#clean up
rm *.blast
rm marker_subset.list
rm marker_subset.fa


