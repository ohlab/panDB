#include <string.h>
#include <map>
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdlib.h>
#include <vector>
#include <ctime>
#include <algorithm>

using namespace std;

int main(int args, char* argv[])
{
	string argv1;
	argv1=argv[1];
	int round=stoi(argv1);


	ifstream input("alignment.maf");
	ofstream output("qblocks.fasta");
	string line;
	vector<string> qblocks;
	for(;getline(input,line);)
	{
		if(line=="") continue;

		if(line[0]=='a') //block statistic line, check # of seqs in the block
		{
			int mult;
			istringstream alinestream(line);
			string mults;
			getline(alinestream,mults,'=');
			getline(alinestream,mults,'=');
			getline(alinestream,mults,'=');
			getline(alinestream,mults,'=');
			mult=stoi(mults);
		
			if(mult==2) continue; //representative sequence in the block
			else
			{
				for(;getline(input,line);)
				{
					if(line[0]=='s')
					{
						istringstream slinestream(line);
						string chr;
						slinestream >> chr;
						slinestream >> chr;
						if(chr.find("query")!=-1)
						{
							string al_siz;
							slinestream >> chr;
							slinestream >> al_siz;
							int al_size=stoi(al_siz);
							//if(al_size<1000) break;

							slinestream >> chr;
							slinestream >> chr;
							slinestream >> chr;
							qblocks.push_back(chr);
						}
						break;
					}
				}
			}
		}
	}
						
	for(int i=0;i<qblocks.size();i++)
	{
		output<<">representative_"<<round<<"_"<<i<<endl;
		output<<qblocks[i]<<endl;
	}
}			
			




//TGGTTCCGCCCTTACGGCGGCTCACTTTTGAA----C---A-GC--G--CA----AAAGTAAGCAAAACGCTCTTACCCCAACACTCGGC

//a score=9489 label=96 mult=18
//s GCA_001307275.CP012831.1		4317647 7681 - 7119102 ATCGCGAGCAAGCTCGCTCCCACAGGGGATCTCCAGCAGGCTGGAGATCGTCTTCCACCCCGTTCAGCACCCGTAATTTCGCAAGGTCAGCGTCAA-CCAAACAATGTGGTT-AGAAACCACACAGGGAGAAAACATGGCTGTTGATATTTTCATCAAGATCGGCGACATCAAGGGCG
