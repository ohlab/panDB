#detect_exogenous.sh

The pipeline was used to identify pan-genomes in panDB that potentially contain exogenous sequences.

A copy of the metaphlan (https://bitbucket.org/biobakery/metaphlan2) marker gene database (metaphlan_markers.fa) and the corresponding information of the entries (markers_info.txt) are included in the repository.


##Dependencies:

* g++ (GCC) 4.9.2
* seqtk https://github.com/lh3/seqtk
* usearch http://www.drive5.com/usearch/

##To run:
* Make a directory to store the sciprts
```
mkdir /home/zhouw/detect_exogenous
```
* Download all scripts in the present folder into the directory
* Specify the path of the scripts directory, the path of the pandb directory, the path of the output directory, the path of the seqtk directory and the path of the usearch directory in env_var.sh.
* Run the wrapper script detect_exogenous.sh, specifying bacteria species name (genus and species separated by a '_'), usearch e-value cut-off, usearch alignment identity cut-off, and the minimum percent of marker gene sequence covered by the alignment. 
```
cd /home/zhouw/detect_exogenous
./detect_exogenous.sh Escherichia_coli 1e-6 0.5 0.5
```

##Output:
* contaminated_taxa.list lists all pan-genomes that contain at least one hit to any marker genes that passes the e-value and identity cut-off
* highConfidentContamination_contigNames.txt lists all pan-genomes, and their contigs that have either 1) at least two hits to any two marker genes that passes the e-value and identity cut-off, or 2) at least one hit to a marker gene while the aligned region > the minimum percentage of the marker gene sequence, specified in the fourth argument. 
* highConfidentContamination_contigCount.txt quantifies the number of contigs in highConfidentContamination_contigNames.txt for each pan-genome
