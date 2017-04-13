# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####

### Download data and needed utilities #####
Download and compile needed codes and download data use the launchme.sh script.

Usage:

#### $  ./launchme.sh \<strain\> \<clean\> 
####    strain= s288c, sk1, n44, cbs, all or none. The  'none' option will only download
	    and compile the utilities needed for the pipelines to work, but will not download
	    any data. You can download data and prepare fastq files for all the strains at once ('all' option) 
	    or in subsequent steps, launching 'launchme.sh strain'  subsequently. 

#### 	clean= if 1 will clean up all the downloaded data not needed by the pipelines.
	       clean=1 will try to download the original ONT fast5 files from which the ONT fastq files are extracted.
	       Deleting the fast5 files for the s288c strain (~630GB)  will prevent you to run the nanopolish pipeline:
			if you decide later to run nanopolish, you will need to re-download the fast5 files..

The first time you launch launchme.sh, it will download and compile needed codes independently 
on the strain/option chosen.

example:     
		$  ./launchme.sh s288c 0

Max disk space required (for clean=0):
s288c:  ~650GB 
sk1:
n44:
cbs:

Total final disk space after cleaning (clean=1): < 30GB.

#### Requirements:
To install 'poretools' a python version >= 2.7 is needed. Please 
make sure this is available in your PATH, together with virtualenv.



### Pipelines
After 'launchme.sh', you can run the  various pipelines, from the 'pipelines' folder

example:	

	cd pipelines	
	./canu.sh <canu_location> <strain> <platform> <cov>

For details on the pipelines look at pipelines/README.md or launch each script with option "-h"

