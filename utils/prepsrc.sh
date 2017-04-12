#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`


##########################################
####### download some utilities ##########
##########################################
cd $thisdir/utils/src

if [ ! -f locpy/bin/activate ]; then
    cd $thisdir/utils/src
    pyversion=`python -c 'import platform; major, minor, patch = platform.python_version_tuple(); print(major);'`
    minor=`python -c 'import platform; major, minor, patch = platform.python_version_tuple(); print(minor);'`


    if [[ $pyversion != 2 ]] && [[ $pyversion != 3 ]]; then
        pyv=`python -c 'import platform; print(platform.python_version())'`
        echo; echo " "Warning!! This script needs python version > 2.7 ! 
        echo "  "python version found is $pyv
        echo "  "Please change python version!!
        exit 1
    elif [[ $pyversion == 2 ]] && [[ $minor < 7 ]]; then
        pyv=`python -c 'import platform; print(platform.python_version())'`
        echo; echo " "Warning!! This script needs python version > 2.7 ! 
        echo "  "python version found is $pyv
        echo "  "Please change python version!!
        exit 1
    fi
    
   virtualenv $thisdir/utils/src/locpy
 fi
exit
    source $thisdir/utils/src/locpy/bin/activate
    pip install --upgrade pip
    pip install --upgrade distribute
    pip install cython
    pip install numpy
    pip install pandas
    pip install panda
    pip install matplotlib
    pip install seaborn
    deactivate
    
#fi

exit
source $thisdir/utils/src/locpy/bin/activate

if [ ! -d  $thisdir/utils/src/poretools ] ; then
    # used to extract fastq from ont fast5
    cd $thisdir/utils/src/
    git clone https://github.com/arq5x/poretools.git
    cd poretools/
    git reset --hard 4e04e25f22d03345af97e3d37bd8cf2bdf457fc9   
    python setup.py install
fi

if [ ! -d  $thisdir/utils/src/pbh5tools ] ; then
   #used to extract fastq from pacbio hdf5 
    cd $thisdir/utils/src
    source $thisdir/utils/src/locpy/bin/activate
    which python
    pip install pysam
    pip install h5py
    pip install pbcore
    git clone https://github.com/PacificBiosciences/pbh5tools.git
    cd pbh5tools
    python setup.py install
fi

if [ ! -d  $thisdir/utils/src/fq2fa ] ; then
    ## fastq 2 fasta
    cd $thisdir/utils/src
    git clone -b nogzstream https://github.com/fg6/fq2fa.git
    cd fq2fa
    make
fi
	
if [ ! -d  $thisdir/utils/src/random_subreads ] ; then
     ## subsample generator
    cd $thisdir/utils/src
    git clone -b YeastStrainsStudy https://github.com/fg6/random_subreads.git
fi

