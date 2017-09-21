#detect_exogenous.sh

The pipeline was used to identify pan-genomes in panDB that potentially contain exogenous sequences.


##Dependencies:

* g++ (GCC)
* seqtk https://github.com/lh3/seqtk
* usearch http://www.drive5.com/usearch/
* bowtie 2 http://bowtie-bio.sourceforge.net/bowtie2/index.shtml
* metaphlan 2 https://bitbucket.org/biobakery/metaphlan2

Note that bowtie2 and metaphlan2 are only used to extract the clade-specific marker genes (only bowtie2-inspect, markers_info.txt and mpa_v20_m200 database are used).

##To run:
* Make a directory to store the sciprts.
```
mkdir /home/zhouw/detect_exogenous
```
* Download all scripts in the present folder into the directory.
* Specify the path of the metaphlan2 directory, the path of the bowtie2 directory, the path of the scripts directory, the path of the pandb directory, the path of the output directory, the path of the seqtk directory and the path of the usearch directory in env_var.sh.
* Run the wrapper script detect_exogenous.sh, specifying bacteria species name (genus and species separated by a '_'), usearch e-value cut-off, usearch alignment identity cut-off, and the minimum percent of marker gene sequence covered by the alignment. 
```
cd /home/zhouw/detect_exogenous
./detect_exogenous.sh Escherichia_coli 1e-6 0.5 0.5
```
* The c++ program hit_analyses was compiled on CentOS 6.7 using gcc 5.3.0. You might want to compile it from source
```
g++ -std=c++11 hit_analyses.cpp -o hit_analyses
```

##Output:
* contaminated_taxa.list lists all pan-genomes that contain at least one hit to any marker genes that passes the e-value and identity cut-off
* highConfidentContamination_contigNames.txt lists all pan-genomes, and their contigs that have either 1) at least two hits to any two marker genes that passes the e-value and identity cut-off, or 2) at least one hit to a marker gene while the aligned region > the minimum percentage of the marker gene sequence, specified in the fourth argument. 
* highConfidentContamination_contigCount.txt quantifies the number of contigs in highConfidentContamination_contigNames.txt for each pan-genome
