# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####


### Download data and needed utilities #####
Download and compile needed codes and download data use the launchme.sh script.

Usage:

	$  ./launchme.sh \<strain\> \<clean\> 
	strain= s288c, sk1, n44, cbs, all or none. 
		The  'none' option will only download and compile the utilities needed for the 
		pipelines to work, but will not download any data. 
		You can download data and prepare fastq files for all the strains at once ('all' option) 
	    	or in subsequent steps, launching 'launchme.sh strain'  subsequently. 

	clean=  if 1 will clean up all the intermediate files from which the fastqs have been extracted.
	       	clean=1 will try to delete the original ONT fast5 files from which the ONT fastq files are extracted.
	       	Warning! Deleting the fast5 files for the s288c strain (~630GB)  will prevent you to run the nanopolish pipeline:
		if you decide later to run nanopolish, you will need to re-download the fast5 files..

The first time you launch launchme.sh, it will download and compile needed codes independently 
on the strain/option chosen.

	example: $  ./launchme.sh s288c 0

#### Disk space required:

##### If not cleaning up (clean=0):
	
s288c:  ~650GB 

sk1:

n44:

cbs:

##### After cleaning (clean=1): 

all strains:  < 30GB.

#### Requirements:
To install 'poretools' a python version >= 2.7 is needed. Please 
make sure this is available in your PATH, together with virtualenv.



### Pipelines
After 'launchme.sh', you can run the  various pipelines, from the 'pipelines' folder
Please notice that the assemblers and scaffolders (except for smis) are not installed 
by the launchme.sh script. To run the pipelines you need to have installations of:
Abruijn (), Canu (), PBcR (), Falcon-integrate (), Smartdenovo (), MiniAsm and MiniMap (), Racon (), nanopolish (),
SPAdes () and  npScarf().
Additional software needed: bwa and samtools 

example:	

	cd pipelines	
	./canu.sh <canu_location> <strain> <platform> <cov>

For details on the pipelines look at pipelines/README.md or launch each script with option "-h"

