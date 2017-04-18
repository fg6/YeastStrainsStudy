# YeastStrainsStudy
Scripts to run pipeline for paper [ref-needed]

## Instructions #####


### Download data and needed utilities #####
Download and install  needed codes and scripts with install.sh:
	
	$ ./install.sh
	
Afterwards, download data and prepare fastq files with the launchme.sh script.

	$  ./launchme.sh <strain> <clean> 
	strain= s288c, sk1, n44, cbs or all  
		You can download data and prepare fastq files for all the strains at once ('all' option) 
	    	or in subsequent steps, launching 'launchme.sh strain'  subsequently. 

	clean=  if 1 will clean up all the intermediate files from which the fastqs have been extracted.
	       	clean=1 will try to delete the original ONT fast5 files from which the ONT fastq files are extracted.
	       	Warning! Deleting the fast5 files for the s288c strain (~630GB)  will prevent you to run the nanopolish pipeline:
		if you decide later to run nanopolish, you will need to re-download the fast5 files..

	example: $  ./launchme.sh s288c 0

Once the data have been downloaded and the fastq files prepared, check the fastq files checksums:

	$ ./utils/docheck.sh <strain> 

        strain= s288c, sk1, n44, cbs or all
                You can check the fastq files for all the strains at once ('all' option)
                or in subsequent steps

If everything looks ok, you can clean up the data folders, deleting every intermediate files and folders:

        example: $  ./launchme.sh <strain> 1

	Warning!! please notice that to run Nanopolish the original fast5 folders are needed, if you clean
		data for the s288c strain, you will not be able to run Nanopolish until you have redownloaded the
		data with ./launchme.sh s288c 0. It is ok to clean up the other strain data.


#### Disk space required:

If not cleaning up (clean=0): Total: 1.5TB

After cleaning (clean=1):  Total: < 30GB.

#### Requirements for installing and preparing data:
To install 'poretools' a python version >= 2.7 is needed. Please 
make sure this is available in your PATH, together with virtualenv.



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

