#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`
singlestrain=$1

if [ $singlestrain != "all" ]; then
    strains=( $singlestrain )
else
    strains=( s288c sk1 cbs n44 )
fi
platforms=( ont pacbio miseq )

miseq_s288c=( fastqs/miseq/18429_1_1.cram )
miseq_cbs=( fastqs/miseq/18429_1_2.cram )
miseq_n44=( fastqs/miseq/18429_1_3.cram )
miseq_sk1=( fastqs/miseq/18429_1_4.cram )


if [ ! -f  $thisdir/utils/src/n50/n50 ] ; then
    echo Some utilities are missing, please run ./launchme.sh install
    exit
fi

platforms=( miseq )
fqlist="$thisdir/utils/fastq_bases.list"


errors=0
missing=0
entries=0

for platform in "${platforms[@]}"; do  
#    echo; echo " *****************"; echo  "   " $platform files:; echo " *****************"; 

    for strain in "${strains[@]}"; do   
#        echo  "   strain=" $strain

	while read -r f1 f2 || [[ -n "$f1" ]]; do
	    file=$f1
	    check=$f2
	    entries=$(($entries+1))

	    thiserror=0

	    
            if [ -f $thisdir/$file ]; then ## file exists
		thischeck=`$thisdir/utils/src/n50/n50 $thisdir/$file | awk '{print $2}'`
		if [ $check != "$thischeck" ]; then 
		    echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		    echo "     !!!! " $file  NOT OK ;  
		    echo "     !!!!    Something went wrong during the fastq preparation "
		    echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
		    errors=$(($errors+1))
		    thiserror=1
		fi
	    else   ## file does not exists
		echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "     Cannot find fastq file for" $strain: $file ;
		errors=$(($errors+1))
		thiserror=1
	    fi


	    if [[ $thiserror != 0 ]]; then  ## if there were errors for this file, check in more details:

		### CHECKS FOR ONT FILES AND FOLDERS ####
		if [ $platform == 'ont' ]; then
		    rm -rf $file

		    thisfolder="${file%_*}"
		    thistar=$thisfolder.tar.gz
			

		    folderok=0
		    if [ -d $thisfolder ]; then
			foldcheck=`du -sh $thisfolder | awk '{print $1}'`
			ocheck=`grep $(basename $thisfolder) $thisdir/utils/f5folders.list | awk '{print $1}'`
			
			
			if [ $foldcheck != $ocheck ]; then 
			    folderok=0
			else
			    folderok=1
			fi
		    fi			

		    if [ $folderok -eq 0 ]; then # if folder not ok, check tar file 
			if [ -f $thistar ]; then
			    
			    tarcheck=`md5sum $thistar | awk '{print $1}'`
			    ocheck=`grep $(basename $thistar) $thisdir/utils/checksum.list | awk '{print $1}'`
			    
			    if [ $tarcheck != $ocheck ]; then 
				echo; echo "     *** PROBLEM FOUND! ***"   
				echo "     The tar file $tarfile did not download properly:"
				echo "       Force redownload it with:"
				echo "         $  ./launchme.sh download" $strain  $(basename $thistar)
			    else
				echo; echo "     *** PROBLEM FOUND! ***"   
				echo "     Uncompression of $thistar in $thisfolder failed"
				rm -rf $thisfolder  
				echo "     !!!!    Please relaunch: $ ./launchme.sh download "  $strain
				echo; echo "     If this does not help, try uncompressing manually:"
				echo "        $ rm -rf " $thisfolder; echo "        $ cd " "${file%/*}"; 
				echo "        $ tar -xvzf " $(basename $thistar)
				echo "        $ cd" $thisdir; echo "        $ ./launchme.sh download" $strain      
			    fi
			else
			    echo "     Cannot find tar.gz file for" $strain: $thistar ;
			    echo "     Force redownload it with:"
			    echo "         $  ./launchme.sh download" $strain  $(basename $thistar)
			fi
			
		    else ## folder ok
			echo; echo "     *** NO PROBLEM FOUND IN EARLIER STEPS ***"   
			echo "     try to simply recreate the file:"
			echo "         $  ./launchme.sh download" $strain 
			
		    fi ## folder not ok?		    
		   	    

		elif [ $platform == 'pacbio' ]; then
		    rm -rf $file 
		    # need to check 4 files : ${file%.*}.1.bax.h5 ${file%.*}.2.bax.h5 ${file%.*}.3.bax.h5 and ${file%.*}.bas.h5
		    tocheck=( 1.bax.h5 2.bax.h5 3.bax.h5 bas.h5 )
		    isok=1

		    
		    for h5file in "${tocheck[@]}"; do  
			thisfile=${file%.*}.$h5file
			if [ -f $thisfile ]; then
			    h5check=`md5sum $thisfile | awk '{print $1}'`
			    ocheck=`grep $(basename $thisfile) $thisdir/utils/checksum.list | awk '{print $1}'`

			    if [ $h5check != $ocheck ]; then 
				isok=0
			    fi
			else
			    echo "     Cannot find file" $thisfile
			    isok=0
			fi
		    done

		    if [[ $isok == 0 ]]; then
			echo; echo "     *** PROBLEM FOUND! ***"   
			echo "     Files "${file%.*}"* did not download properly:"
			echo "       Force redownload them with:"
			echo "         $  ./launchme.sh download" $strain  $(basename ${file%.*}) 
		    fi
	    

	    
	    elif [ $platform == 'miseq' ]; then
		    rm -rf $file 
		    
		    isok=1

		    thislist=miseq_${strain}[@]
		    for cramfile  in "${!thislist}"; do   # loop over ont runs		    
			if [ -f $cramfile ]; then
			    check=`md5sum $cramfile | awk '{print $1}'`
			    ocheck=`grep $(basename $cramfile) $thisdir/utils/checksum.list | awk '{print $1}'`

		
			    if [ $check != $ocheck ]; then 
				isok=0
			    fi
			else
			    isok=0
			fi
		    done

		    if [[ $isok == 0 ]]; then
			echo; echo "     *** PROBLEM FOUND! ***"   
			echo "     File $cramfile did not download properly or is missing:"
			echo "       Redownload it and re-create the fastq file with:"
			echo "         $  ./launchme.sh download" $strain 
		    fi

		fi # platform		
	    fi ## if errors found
	    


	done < <( grep $strain "$fqlist" | grep $platform )


    done		
done




if [[ $entries > 0 ]]; then
   if [[ $missing != 0 ]] || [[ $errors != 0 ]]; then
	echo; echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
	echo "      Some files failed to download or un-compress properly "
	echo "     Please check the warnings above and follow instructions "
	echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
   else
       echo; echo "     All your intermediate files appear to be fine,"
       echo "     if './launchme.sh check strain' failed, try to recreate the fastq files with './launchme.sh download strain' "
   fi
fi
  

