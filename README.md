# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####


### Download data and needed utilities #####
Download and compile needed codes and download data use the launchme.sh script.
The launchme.sh take as input the strain/s whose you want to download; possible
inputs are: s288c, sk1, n44, cbs, all or none. The  'none' option will only download
and compile the utilities needed for the pipelines to work, but will not download
any data. You can download data and prepare fastq files for all the strains at once ('all' option) 
or in subsequent steps, launching 'launchme.sh strain'  subsequently. 
The first time you launch launchme.sh, it will download and compile needed codes independently 
on the strain/option chosen.

example:     
		$  ./launchme.sh s288c

Please note that downloading data and preparing the fastq files is very time consuming. 
Max disk space required during data preparation:

s288c: ont ~630GB  (pacbio 26GB)
sk1:
n44:
cbs:
Final disk occupied smaller as intermediate files are deleted. 
Total final disk space required: < 30GB.

#### Requirements:
To install 'poretools' a python version >= 2.7 is needed. Please 
make sure this is available in your PATH, together with virtualenv.



### Pipelines
After 'launchme.sh', you can run the  various pipelines, from the 'pipelines' folder

example:	

	cd pipelines	
	./canu.sh <canu_location> <strain> <platform> <cov>

For details on the pipelines look at pipelines/README.md or launch each script with option "-h"

