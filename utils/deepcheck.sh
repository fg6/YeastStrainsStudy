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
		    echo "     !!!!    Please "; 
		    echo "     !!!!       1. remove the fastq file: $ rm -f " $file
		    echo "     !!!!       2. relaunch: $ ./launchme.sh download "  $strain
		    echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
		    errors=$(($errors+1))


		    if [ $platform == 'ont' ]; then
		    
			echo folder:
			ls $(basename $file .fastq)
			echo tar:
			ls $(basename $file .fastq).tar.gz


		    fi

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
			foldchek=`du -sh $thisfolder | awk '{print $1}'`
		     	folderok=0

		    fi
		    
		    if [ $folderok -eq 0 ]; then # if folder not ok, check tar file 
			if [ -f $thistar ]; then
			    tarcheck=`du -sh $thistar | awk '{print $1}'`
			    ocheck=`grep $(basename $thistar) $thisdir/utils/tarfiles.list | awk '{print $1}'`

			    if [ $tarcheck != $ocheck ]; then 
				echo "     The tar file $tarfile did now download properly:"
				echo "     Force redownload it with:"
				echo "         $  ./launchme.sh download" $strain  $(basename $thistar)
			    else
				echo the tar file is ok
			    fi
			else
			    echo "     Cannot find tar.gz file for" $strain: $thistar ;
			    echo "     Force redownload it with:"
			    echo "         $  ./launchme.sh download" $strain  $(basename $thistar)
			fi
		    fi




		fi
	        missing=$(($missing+1))
	    fi

	done < <( grep $strain "$fqlist" | grep $platform )


	
	if [[ $entries > 0 ]]; then
	    if [[ $missing != 0 ]] || [[ $errors != 0 ]]; then
		echo;echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "      Some files failed to download or un-compress properly "
		echo "     Please check the warnings above and follow instructions "
		echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
	    else
		echo "   Good news: all your files appear to be fine "
	    fi
	fi
    done
done
