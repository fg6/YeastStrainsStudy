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

platforms=( ont )
fqlist="$thisdir/utils/fastq_bases.list"
#fqlist="$thisdir/utils/test.list"


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

	    
            if [ -f $thisdir/$file ]; then
		thischeck=`$thisdir/utils/src/n50/n50 $thisdir/$file | awk '{print $2}'`

		if [ $check != "$thischeck" ]; then 
		    echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		    echo "     !!!! " $file  NOT OK ;  
		    echo "     !!!!    Something went wrong during the fastq preparation "
		    echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
		    errors=$(($errors+1))


		    if [ $platform == 'ont' ]; then
			rm -rf $file

			thisfolder="${file%_*}"
			thistar=$thisfolder.tar.gz
			

			folderok=0
			if [ -d $thisfolder ]; then
			    foldcheck=`du -sh $thisfolder | awk '{print $1}'`
			    #ocheck=`grep $(basename $thisfolder) $thisdir/utils/f5folders.list | awk '{print $1}'`
			    ocheck=12G #canc
			    
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
			
			

		    fi # platform

		fi


	    else
		echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "     Cannot find fastq file for" $strain: $file ;
		errors=$(($errors+1))

		if [ $platform == 'ont' ]; then
		    thisfolder="${file%_*}"
		    thistar=$thisfolder.tar.gz
		    

		    folderok=0
		    if [ -d $thisfolder ]; then
			foldcheck=`du -sh $thisfolder | awk '{print $1}'`
			#ocheck=`grep $(basename $thisfolder) $thisdir/utils/f5folders.list | awk '{print $1}'`
			ocheck=12G #canc
			
			if [ $foldcheck != $ocheck ]; then 
			    #echo "      Problems with the folder $thisfolder:"
			    #echo "          checking if it's an un-compression problem or a download problem"
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
				# the tar file looks ok, so there is probably an error in uncompressing
				echo "     Uncompression of $thistar in $thisfolder failed"
				#rm -rf $thisfolder  #canc
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

		fi  ## platform

	        missing=$(($missing+1))
	    fi

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
