
C++ code to get the 31X subsample from s288c PacBio dataset use din paper [add ref] 

Usage: ./n50 \<reads.fastq/fasta(.gz)\>


Requirements:
- gzstream in the CPLUS_INCLUDE_PATH
  
To compile:
- source ./compile.sh 
  this will check if gzstream is available in the CPLUS_INCLUDE_PATH and them compile
  otherwise please include the full path to gzstream in the mygzstream on the first line of compile.sh
