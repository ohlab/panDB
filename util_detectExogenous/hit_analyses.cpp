#include <string>
#include <map>
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdlib.h>
#include <vector>
#include <algorithm>

using namespace::std;

int main(int argc, char* argv[])
{

	string argv1=argv[1];
	double cutoff=stod(argv1);

	ifstream fileList("contaminated_taxa.list");

	string fileName;

	ofstream out1("highConfidentContamination_contigCount.txt");
	ofstream out2("highConfidentContamination_contigNames.txt");
	for(;getline(fileList,fileName);)
	{
		//from here, a blast output file / species

		ifstream blastOut(fileName.c_str());

		istringstream fileNamestream(fileName);
		string species;
		getline(fileNamestream, species,'.');

		string line;
		map<string, int> contig_hits;
		map<string, int> contig_longHits;
		vector<string> contigs;
		for(;getline(blastOut,line);)
		{
			istringstream linestream(line);
			string contig;
			double geneLength;
			double alignmentLength;
			string field;

			linestream >> field >> contig >> field >> geneLength >> field >> alignmentLength;

			if(find(contigs.begin(),contigs.end(),contig)==contigs.end()) contigs.push_back(contig);
			if(contig_hits.find(contig)!=contig_hits.end()) contig_hits[contig]++;
			else contig_hits[contig]=1;

			if(alignmentLength/geneLength>=cutoff) 
			{
				if(contig_longHits.find(contig)!=contig_longHits.end()) contig_longHits[contig]++;
				else contig_longHits[contig]=1;
			}

			
		}

		int cnt=0;
		for(auto contig : contigs)
		{
			int confident=0;
			
			if(contig_hits[contig] > 1) confident=1;
			if(contig_longHits.find(contig) != contig_longHits.end()) confident=1;

			if(confident) 
			{
				cnt++;
				out2<<species<<"\t"<<contig<<endl;
			}

		}

		if(cnt>0)
		out1 << species<<"\t"<<cnt<<endl;
	}

}		
