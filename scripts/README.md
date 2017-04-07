These are general info, for details launch each script with option "-h"



# Scripts for long-reads only assembly pipelines #

scripts: abruijn.sh  canu.sh  falcon.sh miniasm.sh  pbcr_miseq.sh  pbcr.sh  racon.sh  smartdenovo.sh

Each script takes as input the location of the pipeline executable (full path), 
the strain to be assembled (s288c,sk1,cbs,n44), the platform of data (ont, pacbio).
Some assembler (miniasm,racon) needs additional inputs (launch single script with "-h" option for details)
For the s288c pacbio case, the read depth sample is required as additional input: 31X (ont-emu subsample) or allX (whole sample)

example: ./canu.sh /full/path/to/canu s288c pacbio 31X


# Nanopolish #

script: nanopolish.sh

This script polishes the s288c ont assembly from Canu, so please before launching it
first launch:
./canu.sh /full/path/to/canu s288c ont
Nanopolish also need the original fast5 files, download them from ENA accession number PRJEB19900.

When Canu is done and the fast5 files are available, launch:
./nanopolish.sh /full/path/to/nanopolish_folder /full/path/to/samtools /full/path/to/bwa /full/path/to/fast5_folder
This will create the results/nanopolish_on_canu_s288c_ont/runnanopolish.sh, 
that can be launched directly on the local machine, although we suggest to run it on a farm



# Scripts for Miseq assembly + long reads scaffolding pipelines #

spades.sh: launch first to create a miseq only assembly
smis.sh, npscarf.sh, hybridspades.sh for scaffolding

...

example:

Warning: please notice that the statistic information collected in the paper
	are for assemblies after contigs smaller than 1000 bp have been eliminated.
	This is especially affecting assemblies based on illumina data.


# Scripts for generating a ont-emu PacBio sample #

ontemu_sub.sh

No input needed, will create a subsample of 31X from pacbio whle sample with read lenghts 
  similar to the ONT pass2D sample (31X). 
  Please be patient, this script will require about XXX min.

Please notice that as a random selection is involved in the subsampling, the final
  subsample will not necessarily have the same reads as the 
  ont-emu sample used in the original analysis (in pacbio_fastq/s288c_pacbio_ontemu_31X.fastq),
  but it will have similar distribution shape and read depth.

example: ./ontemu_sub.sh






