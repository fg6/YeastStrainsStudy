#include <iomanip>  //setprecision
#include <algorithm>    // sort, reverse
#include <vector>  //setprecision
#include <iostream>
#include <fstream>
#include <sstream>

using std::cout;
using std::endl;
using std::vector;
using std::string;

//static gzFile fp;
static  vector<int> rlen;
static  vector<string> rseq;
static  vector<string> rqual;
static  vector<string> rname;
static  vector<string> rcomment;
static std::ofstream myfile;

#include <map>
static  std::map<string, int> readmap;

bool fexists(const std::string& filename) {
  std::ifstream ifile(filename.c_str());
  return (bool)ifile;
}

string myrename(string myname, string exte=""){

  size_t pos = 0;
  string token;
  string delimiter = "/";

  while ((pos = myname.find(delimiter)) != std::string::npos) {
    token = myname.substr(0, pos);
    myname.erase(0, pos + delimiter.length());
  }

  pos=0;

  if(exte.size()){  //change file extension
    token=myname;
    pos   = token.find_last_of(".");
    if (pos != std::string::npos) {	
	token.erase(pos,myname.size());
   }
   myname=token+exte;
  }

  return(myname);
}



// ---------------------------------------- //
int fasttype(char* file)
// ---------------------------------------- //
{ 
  char fq[5]={"@"};
  char fa[5]={">"};
  string ttname;
  int isfq=0;
  std::ifstream infile(file);

  getline(infile,ttname);
  string ftype=ttname.substr(0,1);
  if(ftype==fa) isfq=0;
  else isfq=1;


  return(isfq);
}

// numeric to string
template <class T>
inline std::string to_string (const T& t)
{
  std::stringstream ss;
  ss << t;
  return ss.str();
}

// ---------------------------------------- //
int getreads(char* file)
// ---------------------------------------- // 
{ 
  std::ifstream infile(file);
  char fq[5]={"@"};
  string read;

  int stop=1;
  while(stop){
    getline(infile,read);
    readmap[read] = 1;
    if(infile.eof()){
      stop=0;
    }
    
    
  }//read loop

  return 0;
}
// ---------------------------------------- //
int readfastq(char* file)
// ---------------------------------------- // 
{ 
  
  std::ifstream infile(file);
  char fq[5]={"@"};
  char fa[5]={">"};
  char plus[5]={"+"};
  int nseq=0;
  int readseq=1;
 
  string read;
  string lname;
  string lcomment="";   
  string lseq="";
  int seqlen=0;
  int quallen=0;
  string lqual;
  int seqlines=0;
  int minlen=0;

  int stop=1;
  while(stop){
    getline(infile,read);
    
    if(read.substr(0,1)==fq){  // name
      nseq++;

      if(nseq>1){ // previous
	if(seqlen>=minlen){

	  
	  if(lqual.size()){
	    if(readmap[lname]){  // only if in predetermined reads
	      myfile << fq << lname ;
	      if(lcomment.size()) myfile << lcomment <<endl;
	      else myfile << endl;
	      myfile << lseq << endl;
	      myfile << "+" << endl << lqual << endl;
	    }
	  }else{
	    cout << " Error! trying to write a fastq but quality string is empty! " << endl;
	  }
	  
	  
	  if(quallen != seqlen)
	    cout << " ERROR! seq length different from quality lenght!! " << endl;
	}
      }
      
      size_t ns=0;
      size_t nt=0;
      ns=read.find(" ");
      nt=read.find("\t");

      if(ns!=std::string::npos) { 
	lname=read.substr(1,ns);
	lcomment=read.substr(ns+1,read.size());
      }else if(nt!=std::string::npos) {
	lname=read.substr(1,nt);
	lcomment=read.substr(nt+1,read.size());
      }else{
	lname=read.erase(0,1);
      }
      
      lseq="";
      lqual="";

      seqlen=0;
      seqlines=0;
      quallen=0;
    }else if(read.substr(0,1)==plus){ // + and qual
      
      for(int ll=0; ll<seqlines; ll++){
	getline(infile,read);
	if(readseq)lqual.append(read);
	quallen+=read.size();
      }
    }else{ // sequence 
      lseq.append(read);
      seqlines++;
      seqlen+=read.size();
    }
 
    // EOF
    if(infile.eof()){ // previous
      if(seqlen>=minlen){

	
	if(lqual.size()){
	  if(readmap[lname]){  // only if in predetermined reads
	    myfile << fq << lname ;
	    if(lcomment.size()) myfile << lcomment <<endl;
	    else myfile << endl;
	    myfile << lseq << endl;
	    myfile << "+" << endl << lqual << endl;
	  }	

	}else{
	  cout << " Error! trying to write a fastq but quality string is empty! " << endl;
	}
	  

	if(quallen != seqlen)
	  cout << " ERROR! seq length different from quality lenght!! " << endl;
      }
      stop=0;
    }


  }//read loop
 
  return 0;
}
