#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`
singlestrain=$1
clean=$2
force=$3


source $thisdir/utils/src/locpy/bin/activate


if [ $# -lt 2 ]  || [ $1 == '-h' ]; then
    echo; echo "  Usage:" $(basename $0) \<strain\> 
    echo "  strain: Download data for this strain [s288c] (s288c,sk1,cbs,n44,all,none)"
    exit
fi


if [ $clean -ne 0 ]; then
    rclean=0
    echo; echo; 
    echo "                              !!!! Warning: !!!!"
    if [ $clean -gt 0 ]; then
	echo "        You are deleting all intermediate files used to generate the fastq files"
    else
	echo "        You are deleting intermediate files used to generate the fastq files "
	echo "                     except the files needed by Nanopolish"
    fi

    echo "           Before cleaning up make sure your fastq files are ok by running: "
    echo "                          ./launchme.sh check STRAIN"
    echo "             with STRAIN=your strain of choice (s288c,sk1,cbs,n44,all,none)"
    echo; 

    if [ $clean -gt 0 ]; then
	echo "     If you want to run Nanopolish you should not delete all intermediate files:"
	echo "         to clean up, but save the files needed by Nanopolish, run instead:"
	echo "                          ./launchme.sh nanoclean STRAIN"
	echo;  echo "              Are you sure you want to clean up everything? [yes,y or no,n]"
    else
	echo "    "
	echo;  echo "              Are you sure you want to clean up folders? [yes,y or no,n]"	
   fi
    read rclean
    if [ $rclean == "y" ] || [ $rclean == "yes" ]; then
	echo "                           Cleaning up then..."
    else
	echo "                            Ok I will stop here!"
	exit
    fi
fi
echo;echo


if  [ $singlestrain == "none" ]; then
    strains=( )
elif [ $singlestrain != "all" ]; then
    strains=( $singlestrain )
else
    strains=( s288c sk1 cbs n44 )
fi



if  [[ $force == "" ]] || [[ $force == 'none' ]]; then
    forceont=0
    forcepacbio=0
    forcereload=0
    forceone=0
elif [[ $force == 'all' ]]; then
    forcereload=1
    forceont=0
    forcepacbio=0
    forceone=0
else
    forcereload=0
    forceone=$force

    if [[ $forceone == m1* ]]; then 
        forcepacbio=1
	forceont=0
    else
        forcepacbio=0
	forceont=1
    fi
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

    ofile=$folder/$strain/prepdata.txt
    wgetfile=$folder/$strain/wget.txt
    echo >> $ofile
    date >> $ofile
    echo "   preparing ONT data for " $strain >> $ofile


    if [ $clean -eq 0 ]; then

	rerun=0
	if [ ! -f $strain\_pass2D.fastq ]; then rerun=1;
	elif [ $strain == "s288c" ] && [ ! -f $strain\_all2D.fastq ]; then rerun=1; 
	fi
	
	echo "   preparing ONT data for " $strain $rerun    
	error=0
	if [[ $rerun == 1  ||  $forcereload == 1  ||  $forceont == 1 ]] ; then   ##  if fastq file is not there already
	    
	    echo "           downloading data "
	    
	    thislist=ont${strain}[@]
	    for tarfile  in "${!thislist}"; do   # loop over ont runs
		file=$ontftp/$tarfile
		fold=$(basename "$tarfile" .tar.gz)
		
		echo "           downloading" $tarfile >> $ofile
		
		
		forcethis=0
  		if [ $forceont == 1 ] && [ $forceone == $(basename $tarfile ) ]; then 
		    echo "           "Force reloading $tarfile
	 	    forcethis=1
		# no need to delete the tar.gz, wget in principle should just restart from where it stopped. 
		# Well no, apparently restarting must be supported by the server, anyway, wget  overwrite the file
	 	    rm -f $strain\_pass2D.fastq $strain\_all2D.fastq  # delete final files so they are regenerated 
		fi 
		
		if [[ ( ! -f $tarfile && ( ! -f $fold\_pass2D.fastq  ||  $forcereload -eq 1 )) || $forcethis == 1 ]]; then  # download if file is not there already	
		    
		    
		    if [[ `wget -S --spider $file 2>&1  | grep exists` ]]; then
	    		wget -nv -c $ontftp/$tarfile &>>$wgetfile 
			
			
			if [[ "$?" != 0 ]]; then
			# trying again
			    echo "     Error downloading file" $tarfile >> $ofile ; echo "      Trying to download again..."
		            wget -nv -c $ontftp/$tarfile &>>$wgetfile
			    
			    if [[ "$?" != 0 ]]; then
				echo "     Failed again, error downloading file" $tarfile >>$ofile ; echo "Please re-launch the script!" >>$ofile
				echo "      Check errors in file" $wgetfile >>$ofile
                        	echo "     Error downloading file" $tarfile;  echo "      Check errors in file" $wgetfile ;
				echo "     Maybe a network problem?  Please re-launch the script!"   
				rm -f $tarfile  # remove file otherwise download will not start again
				error=$(($error+1))
				exit
			    fi
			fi
			
			
		    else 
			echo "      !!! Unexpected Error! Could not find url " $file 
			error=$(($error+1))
		    fi
		fi
		
		
		
		echo "           untar-ring data " >> $ofile
		if [[ ( ! -d $fold  && ( ! -f $fold\_pass2D.fastq ||  $forcereload -eq 1 ))  || $forcethis == 1 ]] ; then # untar if not done already
		    
		    if [ $forcereload -eq 1 ]  || [ $forcethis -eq 1 ]; then rm -rf $fold; fi
		    tar -xvzf $tarfile  > /dev/null 2>>$ofile 
		    
		    if [[ "$?" != 0 ]]; then
			echo "Error uncompressing file" $tarfile >>$ofile ; 
			echo "Error uncompressing file" $tarfile; 
			rm -rf $fold
  			echo "Please re-launch the script!"
			error=$(($error+1))
		    fi
		fi
		
            
		if [ ! -f $fold\_pass2D.fastq ]  ||  [ $forcereload -eq 1 ] || [ $forcethis == 1 ]; then  # extract fastq from fast5, if not done already
                    if [ $forcereload -eq 1 ] || [ $forcethis == 1 ]; then rm -f $fold\_pass2D.fastq $fold\_fail2D.fastq $strain\_pass2D.fastq $strain\_all2D.fastq; fi  
                                         # if one of the file is force reloaded, make sure the final fastq files are regenerated!
		    echo "           creating fastqs " >> $ofile
	        
		    fast5pass=$fold/reads/downloads/pass
		    fast5fail=$fold/reads/downloads/fail
		    if ! ls $fast5pass  &> /dev/null; then
			echo; echo "           !!! Some Errors occurred in folder"  $fold
			echo "           please restart the script"
			echo "           If this does not help try debugging with:"
			echo "             $ ./launchme.sh check" $strain     or     "$ ./launchme.sh deepcheck" $strain; echo ;echo
			nfiles=0
			rm -rf $fold
			error=$(($error+1))
		    else
			nfiles=`ls $fast5pass | wc -l`
		    fi
		    
		    if [ $nfiles -gt 0 ]; then
			poretools fastq --type 2D $fast5pass > $fold\_pass2D.fastq  2>>$ofile
			if [ $strain == "s288c" ]; then
		    	    poretools fastq --type 2D $fast5fail > $fold\_fail2D.fastq 2>>$ofile
			fi
		    fi
		fi ## poretools
	    done # runs
	    
	## fastq files created, now merge them:

    	    if ! ls *fastq  &> /dev/null; then
		fqs=0
	    else
		fqs=`ls *fastq | wc -l` 
	    fi
	    
	    if [ $fqs -eq 0 ] || [ $error -gt 0 ]; then  
		echo; echo "           !!! Some Errors! no ONT fastqs created. Please restart the script for "  $strain
		echo "           If this does not help try debugging with:"
		echo "             $ ./launchme.sh check" $strain     or     "$ ./launchme.sh deepcheck" $strain; echo ;echo
	    else
		echo "           merging fastqs " >> $ofile
		echo "           merging fastqs "
		
		
		if [ $forcereload -eq 1 ]; then rm -f $strain\_pass2D.fastq $strain\_all2D.fastq; fi
		for f in *.fastq; do 
		    if [ -f $strain\_pass2D.fastq ]; then 
			if [[ $strain\_pass2D.fastq != $f ]]; then
			    if [[ $f -nt $strain\_pass2D.fastq ]]; then
				rm -f $strain\_pass2D.fastq  $strain\_all2D.fastq  # if there are newly downloaded fastq make sure to regenerate the final fastqs!
			    fi
			fi
		    fi
		done
		
		for f in *_pass2D.fastq; do 
		    cat $f >> $strain\_pass2D.fastq
		done 
		chmod -w $strain\_pass2D.fastq
		
		if [ $strain == "s288c" ]; then
                    echo "          creating fastq for all2D " >> $ofile
		    
	            cp $strain\_pass2D.fastq $strain\_all2D.fastq
                    chmod +w $strain\_all2D.fastq	
		    
		    for f in *fail2D.fastq; do 
			cat $f >> $strain\_all2D.fastq
		    done
		    chmod -w $strain\_all2D.fastq
		fi
	    fi
    
	fi ## if ! global fastq file 

    else  ## clean

        # clean all except fastq files before starting next strain
	if [ -f $strain\_pass2D.fastq ]; then 
	    notempty=`head -1 $strain\_pass2D.fastq | wc -l`
	    
	    if [ $notempty -gt 0 ]; then
		if [ $strain == "s288c" ] && [ $clean -gt 0 ]; then
		    ontclean=0
		    reallyclean=0
		    echo "           Warning: if you delete the fast5 files you will not be able to run nanopolish!"
		    echo "           are you sure you want to clean up the fast5 files? [yes,y or no,n] 
                                (\'no\' will not delete the s288c fast5, but the script will continue to clean up the rest of the data)"
		    read reallyclean
		    if [ $reallyclean == "y" ] || [ $reallyclean == "yes" ]; then
			ontclean=1
		    else
			ontclean=0
		    fi
		else
		    ontclean=$clean
		fi
		
		if [ $clean -lt 0 ]; then  # clean keep files for nanopolish
		    if  [ $strain != "s288c" ]; then # clean all for other strains
			ontclean=1
		    else
			ontclean=0
			rm -f *tar.gz
		    fi
		fi
		
		if [ $ontclean -gt 0 ]; then
		    dd=`ls  --ignore="*txt" --ignore="*fastq" | wc -l`
		    if [ $dd -gt 0 ]; then  
			rm -r $(ls --ignore="*txt" --ignore="*fastq")
		    fi
		fi
	    fi
	fi	
    fi
done # strain

#################################################
#******************* PacBio ******************* #
#################################################

folder=$thisdir/fastqs/pacbio
mkdir -p $folder
cd $folder


for strain in "${strains[@]}"; do   ## loop on strains
    mkdir -p $folder/$strain
    cd  $folder/$strain


    if [ $clean -eq 0 ]; then

	ofile=$folder/$strain/prepdata.txt
	wgetfile=$folder/$strain/wget.txt
	echo >> $ofile
	date >> $ofile
	echo "   preparing PacBio data for" $strain >> $ofile
	
	
	echo "   preparing PacBio data for" $strain
	
	rerun=0
	if [ ! -f $strain\_pacbio.fastq ]; then rerun=1;
	elif [ $strain == "s288c" ] && [ ! -f s288c_pacbio_ontemu_31X.fastq ]; then rerun=1;
	fi
	
	toterror=0  
	
	if [ $rerun -eq 1 ] || [ $forcereload -eq 1 ] || [ $forcepacbio == 1 ]; then  ##  if fastq file is not there already or force reload
	    
	    runs=pb${strain}[@]
       	    for run in "${!runs}"; do   ## loop over pacbio runs
		
		runerror=0    
		thislist=pb$strain\_${run}[@]
		for h5file  in "${!thislist}"; do # loop over pacbio runs
		    forcethis=0
  		    if [[ $forcepacbio == 1 ]]; then
			if [[ $(basename $h5file) == $forceone* ]]; then 
			    echo "           "Force reloading $h5file
	 		    forcethis=1
			    rm -f  $(basename $h5file .bas.h5).fastq $strain\_pacbio.fastq s288c_pacbio_ontemu_31X.fastq
			fi 	
		    fi
		    
		    if [ ! -f $(basename $h5file) ] || [ $forcereload -eq 1 ] || [ $forcethis == 1 ]; then  # download if file is not there already
			echo "           downloading" $h5file >> $ofile	
			
			if [[ $ii == 0 ]]; then echo "           downloading " $h5file; fi
			if [[ `wget -S --spider $h5file 2>&1  | grep exists` ]]; then
			    wget  -nv -c $h5file &>> $wgetfile 
			    
			    if [[ "$?" != 0 ]]; then
				echo "     Error downloading file" $h5file >> $ofile ; echo "      Trying to download again..."
				wget  -nv -c $h5file &>> $wgetfile 
				
				if [[ "$?" != 0 ]]; then
				    echo "     Failed again, error downloading file" $h5file >>$ofile ; echo "Please re-launch the script!" >>$ofile
				    echo "      Check errors in file" $wgetfile >>$ofile
                        	    echo "     Error downloading file" $h5file;  echo "      Check errors in file" $wgetfile ;
				    echo "     Maybe a network problem?  Please re-launch the script!"   
				    
				    rm -f $(basename $h5file)
				    toterror=$(($toterror+1))
				    runerror=$(($runerror+1))
				    exit
				fi
			    fi
			    
			else 
			    echo "      !!! Unexpected Error! Could not find url " $h5file &>> $ofile 
			    echo "      !!! Unexpected Error! Could not find url " $h5file 
			    toterror=$(($toterror+1))
			    runerror=$(($runerror+1))
			fi
		    fi
		done  # download each file in a run
		
		if [ $forcereload -eq 1 ]; then rm -f *.fastq; fi
		
		
		if [[ $runerror == 0 ]]; then
		    for file in *.bas.h5; do
			echo "           extracting fastqs using bash5tools.py" $file >> $ofile
		    #echo "           extracting fastqs using bash5tools.py" $file 
			if [ ! -f $(basename $file .bas.h5).fastq ]; then
			    python $thisdir/utils/src/pbh5tools/bin/bash5tools.py --minLength 500 --minReadScore 0.8000 --readType subreads --outType fastq $file #&>>$ofile 
			fi
		    done
		fi
	    done  ## runs
	    
	    
	    if [[ $toterror == 0 ]]; then
	    # fastq per run ready: now merge them in a single file
		echo "           merging fastqs " >> $ofile
            #echo "           merging fastqs " 
		
		if [ $forcereload -eq 1 ]; then 
		    rm -f $strain\_pacbio.fastq s288c_pacbio_ontemu_31X.fastq; 
		fi
		
		for f in *.fastq; do 
		    if [ -f $strain\_pacbio.fastq ]; then 
			if [[ $strain\_pacbio.fastq != $f ]]; then
			    if [[ $f -nt $strain\_pacbio.fastq ]]; then
				rm -f $strain\_pacbio.fastq  s288c_pacbio_ontemu_31X.fastq  # if there are newly downloaded fastq make sure to regenerate the final fastqs!
			    fi
			fi
		    fi
		done
		
		if [ ! -f $strain\_pacbio.fastq ]; then 
		    for f in *.fastq; do 
			cat $f >> $strain\_pacbio.fastq
		    done
     		fi 
		chmod -w $strain\_pacbio.fastq
		
		if [ $strain == "s288c" ] && [ ! -f s288c_pacbio_ontemu_31X.fastq ] ; then
		    echo "           recreating pacbio s288c subsample 31X ONT-Emu"  
		    echo "           recreating pacbio s288c subsample 31X ONT-Emu"  >> $ofile
		    $thisdir/utils/src/pacbiosub/pacbiosub $strain\_pacbio.fastq $thisdir/utils/src/pacbiosub/pacbio_31X_reads.txt &>>$ofile 
		fi
		
	    else
		echo; echo "           !!! Some Errors! no PacBio fastqs created. Please restart the script for"  $strain
		echo "           If this does not help try debugging with:"
		echo "             $ ./launchme.sh check" $strain     or     "$ ./launchme.sh deepcheck" $strain; echo ;echo
	    fi
	fi ## if ! global fastq file 
    

    else ## clean

        # if all successful: clean all except fastq files before starting next strain
	if [ $clean -gt 0 ]; then
	    dd=`ls  --ignore="*txt" --ignore="*fastq" | wc -l`
	    if [ $dd -gt 0 ]; then  
		rm -r $(ls --ignore="*txt" --ignore="*fastq")
	    fi
	fi
    fi
   
done


################################################
#******************* MiSeq ******************* #
################################################

folder=$thisdir/fastqs/miseq
mkdir -p $folder
cd $folder


for strain in "${strains[@]}"; do
    mkdir -p $folder
    cd  $folder


    ofile=$folder/$strain\_prepdata.txt
    wgetfile=$folder/$strain\_wget.txt

    echo > $ofile
    date >> $ofile
    if [ $clean -eq 0 ]; then

	echo "   preparing MiSeq data for " $strain
	echo "   preparing MiSeq data for " $strain  >> $ofile

	thislist=miseq_${strain}[@]
	for cramfile in "${!thislist}"; do
	    file=$miseqftp/$cramfile
	    myfile=`echo $cramfile | sed 's/%23/#/g'`

	    if [ ! -f $strain\_1.fastq ] || [ ! -f $strain\_2.fastq ]  || [ $forcereload -eq 1 ]; then		
		if [ $forcereload -eq 1 ]; then rm -f $strain\_?.fastq; fi
				
		if [ ! -f $folder/$myfile ]; then
		    if [[ `wget -S --spider $file 2>&1  | grep exists` ]]; then
			wget  -nv -c $file &> $wgetfile 
			
			if [[ "$?" != 0 ]]; then
			    echo "     Error downloading file" $file >> $ofile ; echo "      Trying to download again..."
			    wget  -nv -c $file &>> $wgetfile 
			    
			    if [[ "$?" != 0 ]]; then
				echo "     Failed again, error downloading file" $file >>$ofile ; echo "Please re-launch the script!" >>$ofile
				echo "     Check errors in file" $wgetfile >>$ofile
				echo "     Error downloading file" $file;  echo "      Check errors in file" $wgetfile ;
				echo "     Maybe a network problem?  Please re-launch the script!"   
				rm -f $(basename $file)
				
				toterror=$(($toterror+1))
				runerror=$(($runerror+1))
				exit
			    fi
			fi
		    else 
			echo "Could not find url " $file
		    fi # if no cramfile found
		fi

		if [ -f $folder/$myfile ]; then
		    rm -f $strain\_1.fastq $strain\_2.fastq
		    $thisdir/utils/src/biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu/bin/bamtofastq inputformat=cram exclude=SECONDARY,SUPPLEMENTARY,QCFAIL F=$strain\_1.fastq F2=$strain\_2.fastq < $myfile &>>$ofile  
		    
		    
   		    #if `grep "failed" $ofile`  &> /dev/null; then
		    #	fails=0
		    #	echo no fails
		    #else
		    #	fails=`grep "failed" $ofile`
	 	    #	echo $fails
		    #fi
		fi
	    fi
	done

    else ## clean
	rm -f *.cram
    fi
done #strain
