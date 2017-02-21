source env_var.sh

cd "$panDB_dir"

#=========args=========
# $1=kingdom
# $2=number of PBS jobs
# $3=qsub resource string
#======================

#--------------1. download data-----------------

quote=\'
sed -i "s/$quote/_/g" "assembly_summary.$1.txt"
sed -i "s/\"/_/g" "assembly_summary.$1.txt"
mkdir "library_test_$1"
cat "assembly_summary.$1.txt" | xargs -I {} ./scripts/download_fna.sh $1 {}

#--------------2. generate representative list---------------

cat "assembly_summary.$1.txt" | grep -F "representative genome" | awk -F '\t' '{print $7 "\t" $1}' > "$1.repr.list"

#--------------3. prepare qsub jobs-----------------

./scripts/job_alloc.sh $1 $2 $3

#--------------4. submit jobs-----------------

cd 
for qsub in "$panDB_dir"/"library_test_$1"/qsub_jobs/*.qsub; do
	qsub "$qsub"
done
