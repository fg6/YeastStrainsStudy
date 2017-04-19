#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`

whattodo=$1
singlestrain=$2


if [ $# -lt 1 ]  || [ $1 == '-h' ]; then
    echo; echo "  Usage:" $(basename $0) \<command\> \<strain\>  
    echo "  command: command to be run. Options: install,download,check,clean"
    echo "  strain: Download data for this strain/s, only for command=download or check [s288c]. Options: s288c,sk1,cbs,n44,all"
    exit
fi


if [[ ${singlestrain} == "" ]]; then
	singlestrain=s288c
fi





##########################################
####### download some utilities ##########
##########################################
if [ $whattodo == "install" ]; then
	echo; echo " Downloading and install some utilities..."
	$thisdir/utils/prepsrc.sh
	echo "                 ... all srcs ready!"
fi


###################################################
  echo; echo " Downloading and preparing data..."
###################################################
if [ $whattodo == "download" ]; then
	cd $thisdir
	$thisdir/utils/prepdata.sh $singlestrain 0
	echo "                 ... requested data ready!"
fi


###################################################
  echo; echo " Downloading and preparing data..."
###################################################
if [ $whattodo == "clean" ]; then
        cd $thisdir
        $thisdir/utils/prepdata.sh $singlestrain 1
        echo "                 ... cleaned data!"
fi



### add check for fastqs
###################################################
  echo; echo " Downloading and preparing data..."
###################################################
if [ $whattodo == "check" ]; then
        cd $thisdir
        $thisdir/utils/docheck.sh $singlestrain 0
fi


