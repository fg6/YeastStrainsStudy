# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####
Download repository: 

	git clone https://github.com/fg6/YeastStrainsStudy.git


### Download data and utilities #####

To download and prepare the data and install the needed scripts and codes use the launchme.sh script:

Usage: 

	$ ./launchme.sh <command> <strain>
	  command: command to be run. Options: install,download,check,deepcheck,clean,nanoclean
  	  strain: Download data for this strain/s, only for command=download or check 
		  Options: s288c,sk1,cbs,n44,all [s288c]

##### Step 1. Download and install needed codes and scripts:
	
	$ ./launchme.sh install
	
##### Step 2. Download data and prepare the fastq files: 

	$ ./launchme.sh download <strain> 
 
	strain= s288c, sk1, n44, cbs or all  [s288c]

##### Step 3. Once the data have been downloaded and the fastq files prepared, check the fastq files:

	$ ./launchme.sh check <strain> 

        strain= s288c, sk1, n44, cbs or all  [s288c]

	If the check give you warnings, probably some file failed to download properly, 
	follow the instructions given in the output
	If the instructions do not help, try with 
	
	$ ./launchme.sh deepcheck <strain>


##### Step 4/A. If everything looks ok and there are no warnings from Step 3, you can clean up the data folders, deleting every intermediate files and folders:

        $ ./launchme.sh clean <strain>

	!!!!!   Warning  !!!!! 
	1. Please run this only after Step 3 and only if Step 3 showed no errors or warnings, 
		otherwise you will have to download everything again!
	2. Please do not run this if you intend to run Nanopolish, 
	        as Nanopolish needs the s288c fast5 files, run instead Step 4/B
 
##### Step 4/B. If everything looks ok and there are no warnings, you can clean up the data folders, deleting every intermediate files and folders not needed by Nanopolish:

        $ ./launchme.sh nanoclean <strain>

        !!!!!   Warning  !!!!!
        Please run this only after Step 3 and only if Step 3 showed no errors or warnings,
          otherwise you will have to download everything again!



##### Disk space required:

If not cleaning up:  1.7TB 

After cleaning all (clean):  < 30GB.

After cleaning all except files for Nanopolish (nanoclean): ~700GB 

##### Requirements for installing and preparing data:
A python version >= 2.7 is needed. Please 
make sure this is available in your PATH, 
together with virtualenv.



### Pipelines
After 'launchme.sh', you can run the  various pipelines, from the 'pipelines' folder

example:	

	cd pipelines	
	./canu.sh <canu_location> <strain> <platform> <cov>

For details on the pipelines look at pipelines/README.md or launch each script with option "-h"

#### Warning! Please notice that the assemblers and scaffolders (except for smis) are not installed by the launchme.sh script. To run the pipelines you need to have installations of:

#### Abruijn (https://github.com/fenderglass/ABruijn)
#### Canu (https://github.com/marbl/canu)
#### PBcR (http://wgs-assembler.sourceforge.net/wiki/index.php/PBcR)
#### Falcon-integrate (https://github.com/PacificBiosciences/FALCON-integrate)
#### Smartdenovo (https://github.com/ruanjue/smartdenovo)
#### MiniAsm and MiniMap (https://github.com/lh3/miniasm,https://github.com/lh3/minimap/)
####  Racon (https://github.com/isovic/racon)
#### Nanopolish (https://github.com/jts/nanopolish)
#### SPAdes (http://bioinf.spbau.ru/spades) 
#### npScarf(https://github.com/mdcao/npScarf).
#### Additional software needed: bwa (https://github.com/lh3/bwa), samtools (https://github.com/samtools/samtools), bamtools (https://github.com/pezmaster31/bamtools)

