#include "readnwritefaq.h"

#include <zlib.h>
#include <stdio.h>

#include <iostream>
#include <fstream>



int main(int argc, char *argv[])
{ 

  if (argc == 2) {
   fprintf(stderr, "Usage: %s <reads.fq/fa> \n", argv[0]);
   return 1;
  }	
  std::ifstream file(argv[1]);  
  if ( ! fexists(argv[1]) ){
    printf("ERROR main:: missing input file  !! \n");
    return 1;
  } 
 
  // read list of reads
  char readfile[21]={"pacbio_31X_reads.txt"};
  getreads(readfile);


  string myname="s288c_pacbio_ontemu_31X.fastq";
  int err=1;

  // File type	
  int isfq=fasttype(argv[1]);

  if(!isfq)
    cout << " Error! not a fastq file! "<<endl;
  else{
    myfile.open(myname.c_str());  
    err=readfastq(argv[1]);
    myfile.close();
  }


//if(!err)calc();  

  return 0;
}


// ---------------------------------------- //
int calc()
// ---------------------------------------- //
{
  sort(rlen.begin(),  rlen.end(), std::greater<int>());

  int n=rlen.size();
  int max=rlen[0];                 	
  float bases = accumulate(rlen.begin(), rlen.end(), 0.0);
  float mean = bases / n;

  int n50=0,l50=0;
  int done=0;
  long int t50=0;
  int ii=0;
  while(done<1){
    t50+=rlen[ii];
    if(t50 > bases*0.5) 
      done=1;
    ii++;
   }

  n50=ii;
  l50=rlen[n50-1];  //counting from 0
  
  std::cout << std::fixed << std::setprecision(0) <<  "Bases= " << bases << " contigs= "<< n << " mean_length= " 
	<< mean << " longest= " << max << " N50= "<< l50 << " n= " << n50   //counting from 1
	<< std::endl;  

  return 0;
}

