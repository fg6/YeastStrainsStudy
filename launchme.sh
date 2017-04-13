#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`

singlestrain=$1
clean=$2

if [ $# -lt 2 ]  || [ $1 == '-h' ]; then
    echo; echo "  Usage:" $(basename $0) \<strain\>  \<clean\>
    echo "  strain: Download data for this strain/s [s288c] (s288c,sk1,cbs,n44,all,none)"
    echo "  clean:  1 to delete all intermediate files. We recommend to launch the first time with clean=0, check that all fastq files are created fine, then relaunch with clean=1. [0] "
    exit
fi


if [ $singlestrain != "all" ]; then
    strains=( $singlestrain )
else
    strains=( s288c sk1 cbs n44 )
fi




###################################################
  echo; echo " Downloading and preparing data..."
###################################################

cd $thisdir
$thisdir/utils/prepdata.sh $singlestrain $clean
echo "                 ... requested data ready!"



### add check for fastqs
