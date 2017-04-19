#include "readnwritefaq.h"

#include <zlib.h>
#include <stdio.h>

#include <iostream>
#include <fstream>



int main(int argc, char *argv[])
{ 

  if (argc < 3) {
   fprintf(stderr, "Usage: %s <reads.fq/fa> <pacbio_reads_list>\n", argv[0]);
   return 1;
  }	
  std::ifstream file(argv[1]);  
  if ( ! fexists(argv[1]) ){
    printf("ERROR main:: missing input file  !! \n");
    return 1;
  } 
 
  // read list of reads
//  char readfile[21]={"pacbio_31X_reads.txt"};
  getreads(argv[2]);


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




  return 0;
}


