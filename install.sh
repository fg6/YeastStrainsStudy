#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`


##########################################
####### download some utilities ##########
##########################################
echo; echo " Downloading and install some utilities..."
$thisdir/utils/prepsrc.sh
echo "                 ... all srcs ready!"

















