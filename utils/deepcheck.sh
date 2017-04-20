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
		    
		    echo folder:
		    ls $(basename $file .fastq)
		    echo tar:
		    ls $(basename $file .fastq).tar.gz
		    errors=$(($errors+1))

		fi
	    else
		echo; echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "     Cannot find fastq file for" $strain: $file ;

		echo folder:
		echo $(basename $file _pass2D.fastq)
		echo tar:
		echo $(basename $file _pass2D.fastq).tar.gz
		errors=$(($errors+1))


	        #echo "          Download it with: "  $ ./launchme.sh download $strain 
	        missing=$(($missing+1))
	    fi

	done < <( grep $strain "$fqlist" | grep $platform )


	
	if [[ $entries > 0 ]]; then
	    if [[ $missing != 0 ]] || [[ $errors != 0 ]]; then
		echo "     !!!!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!!!!!! " 
		echo "      Some files failed to download or un-compress properly "
		echo "     Please check the warnings above and follow instructions "
		echo "     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " 
	    else
		echo "   Good news: all your files appear to be fine "
	    fi
	fi
    done
done
