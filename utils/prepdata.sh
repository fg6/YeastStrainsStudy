#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`
singlestrain=$1
clean=$2

if [ $# -lt 2 ]  || [ $1 == '-h' ]; then
    echo; echo "  Usage:" $(basename $0) \<strain\> 
    echo "  strain: Download data for this strain [s288c] (s288c,sk1,cbs,n44,all,none)"
    exit
fi

if  [ $singlestrain == "none" ]; then
    strains=( )
elif [ $singlestrain != "all" ]; then
    strains=( $singlestrain )
else
    strains=( s288c sk1 cbs n44 )
fi


# get name and location of data
source $thisdir/utils/runlist.sh


#use local python
source $thisdir/utils/src/locpy/bin/activate


##############################################
#******************* ONT ******************* #
##############################################

folder=$thisdir/fastqs/ont

mkdir -p $folder
cd $folder

for strain in "${strains[@]}"; do   ## loop on strains
    mkdir -p $folder/$strain
    cd  $folder/$strain


    echo "   preparing ONT data for " $strain
    if [ ! -f $strain\_pass2D.fastq ]; then   ##  if fastq file is not there already

	thislist=ont${strain}[@]
	for tarfile  in "${!thislist}"; do   # loop over ont runs
	    file=$ontftp/$tarfile
	    fold=$(basename "$tarfile" .tar.gz)
	    
	    if [ ! -f $tarfile ] && [ ! -f $fold\_pass2D.fastq ] ; then  # download if file is not there already
		if [[ `wget -S --spider $file 2>&1  | grep exists` ]]; then
	    	    wget $ontftp/$tarfile
		else 
		    echo "Could not find url " $file
		fi
	    fi

	    if [ ! -d $fold ] && [ ! -f $fold\_pass2D.fastq ] ; then # untar if not done already
		tar -xvzf $tarfile
		echo untar
	    fi
	    
	    if [ ! -f $fold\_pass2D.fastq ]; then  # extract fastq from fast5, if not done already
		
		fast5pass=$fold/reads/downloads/pass
		fast5fail=$fold/reads/downloads/fail
		if ! ls $fast5pass  &> /dev/null; then
		    echo "  " no fast5 found! $fast5pass
		    nfiles=0
		else
		    nfiles=`ls $fast5pass | wc -l`
		fi
		if [ $nfiles -gt 0 ]; then
		    poretools fastq --type 2D $fast5pass > $fold\_pass2D.fastq
		    if [ $strain == "s288c" ]; then
		    	poretools fastq --type 2D $fast5fail > $fold\_fail2D.fastq
		    fi
		else
		    echo no fast5 found! $fast5pass
		fi
	    fi ## poretools
	done # runs
    
	## fastq files created, now merge them:

    	if ! ls *fastq  &> /dev/null; then
	    fqs=0
	else
	    fqs=`ls *fastq | wc -l` 
	fi
	
	if [ $fqs -eq 0 ]; then  
	    echo; echo " Error! no ONT fastqs found or creaed"  $strain
	else
	    echo " Merging " $fqs "fastqs for the " $strain " strain"
	    
	    for f in *_pass2D.fastq; do 
		cat $f >> $strain\_pass2D.fastq
	    done 
	    chmod -w $strain\_pass2D.fastq

	    if [ $strain == "s288c" ]; then
	        cp $strain\_pass2D.fastq $strain\_all2D.fastq
		for f in *fail2D.fastq; do 
		    cat $f >> $strain\_all2D.fastq
		done
		chmod -w $strain\_all2D.fastq
	    fi
	fi
    
    fi ## if ! global fastq file 

    # clean all except fastq files before starting next strain
    if [ -f $strain\_pass2D.fastq ]; then 
	notempty=`head -1 $strain\_pass2D.fastq | wc -l`
	if [ $notempty -gt 0 ] && [ $clean -gt 0 ]; then
	    dd=`ls -I "*fastq" | wc -l`
	    if [ $dd -gt 0 ]; then  
		rm -r $(ls -I "*fastq")
	    fi
	fi
    fi
done # strain

#******************* PacBio ******************* #

folder=$thisdir/fastqs/pacbio
mkdir -p $folder
cd $folder


for strain in "${strains[@]}"; do   ## loop on strains
    mkdir -p $folder/$strain
    cd  $folder/$strain

    echo "   preparing PacBio data for " $strain

    if [ ! -f $strain\_pacbio.fastq ]; then  ##  if fastq file is not there already

	runs=pb${strain}[@]
	for run in "${!runs}"; do   ## loop over pacbio runs
	    
	    thislist=pb$strain\_${run}[@]
	    for tarfile  in "${!thislist}"; do # loop over pacbio runs
		if [ ! -f $(basename $tarfile) ]; then  # download if file is not there already
		    if [[ `wget -S --spider $tarfile 2>&1  | grep exists` ]]; then
			wget $tarfile
		    else 
			echo "Could not find url " $tarfile
		    fi
		fi
	    done  # download each file in a run

	    # files are downloaded, now extract fastq 	    
	    for file in *.bas.h5; do
		if [ ! -f $(basename $file .bas.h5).fastq ]; then
		    python $thisdir/utils/src/pbh5tools/bin/bash5tools.py --minLength 500 --minReadScore 0.8000 --readType subreads --outType fastq $file 
		fi
	    done
	    
	done  ## runs

	# fastq per run ready: now merge them in a single file
	for f in *.fastq; do 
	    cat $f >> $strain\_pacbio.fastq
	done 
	chmod -w $strain\_pacbio.fastq


	if [ $strain == "s288c" ]; then
	    echo recreate pacbio s288c subsample 31X

	fi
	
   fi ## if ! global fastq file 

   # if all successful: clean all except fastq files before starting next strain
   if [ -f $strain\_pacbio.fastq ]; then 
	notempty=`head -1 $strain\_pacbio.fastq | wc -l`
	if [ $notempty -gt 0 ] && [ $clean -gt 0 ]; then
	    dd=`ls -I "*fastq" | wc -l`
	    if [ $dd -gt 0 ]; then  
		rm -r $(ls -I "*fastq")
	    fi
	fi
   fi
   
done

#******************* MiSeq ******************* #

folder=$thisdir/fastqs/miseq
mkdir -p $folder
cd $folder

for strain in "${strains[@]}"; do
    mkdir -p $folder
    cd  $folder
    echo "   preparing MiSeq data for " $strain

    thislist=miseq_${strain}[@]
   
    for cramfile in "${!thislist}"; do
	file=$miseqftp/$cramfile
	if [ ! -f $strain\_1.fastq ]; then
	    if [[ `wget -S --spider $file 2>&1  | grep exists` ]]; then
	    	wget $file  &> /dev/null
		$thisdir/utils/src/biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu/bin/bamtofastq inputformat=cram exclude=SECONDARY,SUPPLEMENTARY,QCFAIL F=$strain\_1.fastq F2=$strain\_2.fastq < $cramfile &>/dev/null
		rm $cramfile
	    else 
		echo "Could not find url " $file
	    fi
	fi
    done
done
