# panDB

The pipeline was used to generate panDB, a microbial reference database that contains pan-genomes of all bacterial, archaeal, fungal and viral species.

The pipeline was designed for parallel processing on a Portable Batch System (PBS).

## Dependencies:

* g++ (GCC) 4.9.2
* Mugsy 1.2.3 http://mugsy.sourceforge.net/

## To run:

* Make a directory to store the intermediate and database files
```
mkdir /home/zhouw/pandb
```
* Move the downloaded scripts folder into the database directory
```
mv /download_path/scripts /home/zhouw/pandb
```
* Specify the path of the database directory and the path of the mugsy directory in env_var.sh
* Download assembly summary files from [NCBI](https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/#asmsumfiles) and place it under the database folder. Rename the assembly summary files to the following format: assembly_summary.KINGDOM.txt. For example, the assembly summary file for bacterial genomes will be named: assembly_summary.bacteria.txt
* Run test.sh for a quick unit test, it downloads three E.coli genome sequences, conducts the iterative alignment and checks if the output of each step is the same as the expected output. The result of the unit test is output to "test_result" under the pandb database directory. Please make sure to run the test before compiling the full database to avoid overwriting. 
* Run wrapper.sh for each kingdom, specifying the number of jobs to create and the resources to request for each job. The wrapper script will download all assemblies, create and send jobs to the PBS system. For example, for bacteria, to create 50 jobs, each requesting 100-hour walltime, 16gb memory, running on one node and one processor:
```
cd /home/zhouw/pandb/scripts
./wrapper.sh bacteria 50 "walltime=100:00:00,mem=16gb,nodes=1:ppn=1"
```

* All pan-genome sequences will be stored in the genome_all_v2 subfolder under the database directory. Each species will have an individual fasta file, named in the following format: KINGDOM_taxID.fa.For example, the pan-genome sequence of Staphylococcus aureus will be named bacteria_1280.fa

## Miscs:

The pipeline will not clean up the downloaded raw assembly files. All assembly files, as well as PBS jobs to extract pan-genome sequences, will be stored in the folder: library_test_KINGDOM. For example, all assembly files and jobs for bacterial genomes will be stored in library_test_bacteria.

The present pipeline will perform at most 50 cycles of iterative alignment to compute the pan-genome sequence. It can be modified in Inti_mugsy.sh, within the section "--3.0 determine the number of cycles--". For example, to perform at most 20 cycles:
```
#--3.0 determine the number of cycles--
nc=$(( ng - 1 ))
if (( ng > 21 )); then nc=20; fi
```
