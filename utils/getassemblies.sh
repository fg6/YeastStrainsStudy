#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`


link=http://www.ebi.ac.uk/biostudies/files/S-BSST17/u/
file=yeast_assemblies.tar.gz

folder=$thisdir/final_fastas
mkdir -p $folder
cd $folder
wgetfile=wget.txt
ofile=output.txt

error=0
if [ ! -d YeastAssemblies ]; then  

    if [ ! -f $file ]; then
	if [[ `wget -S --spider $link/$file 2>&1  | grep exists ` ]]; then
            wget -nv -c  $link/$file &>>$wgetfile
	    
	    if [[ "$?" != 0 ]]; then
		echo "     Error downloading file, try again" 
		error=$(($error+1))
		rm -f $file
		exit
	    fi
	else
            echo "    !!! Unexpected Error! Could not find url " $link/$file 
            error=$(($error+1))
	fi
    fi
    
    if [[ $error == 0 ]]; then

	tar -xvzf $file  > /dev/null 2>>$ofile
	
    else
	echo there were some errors during downloading..try again
	exit
    fi # if error 
fi


if [ -d YeastAssemblies ]; then  
    echo "   "The final assemblies are in folder final_fastas/YeastAssemblies
    echo "   "Check details about each file in final_fastas/YeastAssemblies/Summary_of_assemblies.txt; 

    echo "     or: ./launchme.sh findassembly <strain>"
    echo
fi