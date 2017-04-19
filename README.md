# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####
Download repository: 

	git clone https://github.com/fg6/YeastStrainsStudy.git


### Download data and utilities #####

To download and prepare the data and install the needed scripts and codes use the launchme.sh script:

Usage: 

	$ ./launchme.sh <command> <strain>
	  command: command to be run. Options: install,download,check,clean
  	  strain: Download data for this strain/s, only for command=download or check 
		  Options: s288c,sk1,cbs,n44,all [s288c]

###### Step 1. Download and install needed codes and scripts:
	
	$ ./launchme.sh install
	
##### Step 2. Download data and prepare the fastq files: 

	$ ./launchme.sh download <strain> 
 
	strain= s288c, sk1, n44, cbs or all  [s288c]

#### Step 3. Once the data have been downloaded and the fastq files prepared, check the fastq files:

	$ ./launchme.sh check <strain> 

        strain= s288c, sk1, n44, cbs or all  [s288c]

	If the check give you warnings, probably some file failed to download properly, follow the instructions given in the output

Step 4. If everything looks ok and there are no warnings, you can clean up the data folders, deleting every intermediate files and folders:

        $ ./launchme.sh clean <strain>

	Warning!! please notice that to run Nanopolish the original fast5 folders are needed for s288c, 
		if you clean data for the s288c strain, you will not be able to run Nanopolish until 
		you download again the fast5 data with ./launchme.sh download s288c. 
		It is ok to clean up the other strain data, as Nanopolish is only run on s288c.


#### Disk space required:

If not cleaning up (clean=0):  1.7TB 

After cleaning all (clean=1):  < 30GB.

After cleaning all except s288c (to run Nanopolish): ~700GB 

#### Requirements for installing and preparing data:
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

