#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`

whattodo=$1
singlestrain=$2
forcereload=$3

if [ $# -lt 1 ]  || [ $1 == '-h' ]; then
    echo; echo "  Usage:" $(basename $0) \<command\> \<strain\>  
    echo "  command: command to be run. Options: install,download,check,clean"
    echo "  strain: Download data for this strain/s, only for command=download or check."
    echo "          Options: s288c,sk1,cbs,n44,all"
    exit
fi


if [[ ${singlestrain} == "" ]]; then
	singlestrain=s288c
fi



if [ $whattodo == "install" ]; then
  ###################################################
  echo; echo " Downloading and installing some utilities..."
  ###################################################

	$thisdir/utils/prepsrc.sh
	echo "                 ... all srcs ready!"
fi



if [ $whattodo == "download" ]; then
  ###################################################
  echo; echo " Downloading and preparing data..."
  ###################################################
	cd $thisdir
	$thisdir/utils/prepdata.sh $singlestrain 0  $forcereload
	echo "                 ... requested data ready!"
fi


if [ $whattodo == "clean" ]; then
  ###################################################
  #### echo " Cleaning data..."
  ###################################################

        cd $thisdir
        $thisdir/utils/prepdata.sh $singlestrain 1
        #echo "                 ... cleaned data!"
fi

if [ $whattodo == "nanoclean" ]; then
  #####################################################################
  echo; echo " Cleaning data saving the fast5 needed to run Nanopolish"
  #####################################################################

        cd $thisdir
        $thisdir/utils/prepdata.sh $singlestrain -1
        #echo "                 ... cleaned data!"
fi



if [ $whattodo == "check" ]; then
  ###################################################
  echo; echo " Checking fastq files..." 
  ###################################################
        cd $thisdir
        $thisdir/utils/docheck.sh $singlestrain
fi

if [ $whattodo == "deepcheck" ]; then
  ###################################################
  echo; echo " Checking intermediate files..." 
  ###################################################
        cd $thisdir
        $thisdir/utils/deepcheck.sh $singlestrain 
fi


