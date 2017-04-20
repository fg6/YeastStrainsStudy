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


if [ ! -f  $thisdir/utils/src/n50/n50 ] ; then
    echo Some utilities are missing, please run ./launchme.sh install
    exit
fi

platforms=( pacbio )
fqlist="$thisdir/utils/fastq_bases.list"

for platform in "${platforms[@]}"; do  
    echo; echo " *****************"; echo  "   " $platform files:; echo " *****************"; 

    for strain in "${strains[@]}"; do   
        echo  "   strain=" $strain

	errors=0
	missing=0
	entries=0

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
			#ocheck=12G #canc
			
			if [ $foldcheck != $ocheck ]; then 
			    folderok=0
			else
			    folderok=1
			fi
		    fi			

		    if [ $folderok -eq 0 ]; then # if folder not ok, check tar file 
			if [ -f $thistar ]; then
			    tarcheck=`du -sh $thistar | awk '{print $1}'`
			    ocheck=`grep $(basename $thistar) $thisdir/utils/tarfiles.list | awk '{print $1}'`
			    
				#ocheck=$tarcheck #canc
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
			    h5check=`du -sh $thisfile | awk '{print $1}'`
			    ocheck=`grep $(basename $thisfile) $thisdir/utils/h5files.list | awk '{print $1}'`
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
			echo "         $  ./launchme.sh download" $strain  $(basename ${file%.*}) ## need to add in prepdata
		    fi

		fi # platform		
	    fi ## if errors found
	    
	done < <( grep $strain "$fqlist" | grep $platform )


	
	if [[ $entries > 0 ]]; then
	    if [[ $missing != 0 ]] || [[ $errors != 0 ]]; then
		echo; echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "      Some files failed to download or un-compress properly "
		echo "     Please check the warnings above and follow instructions "
		echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
	    else
		echo "   Good news: all your files appear to be fine "
	    fi
	fi
    done
done
