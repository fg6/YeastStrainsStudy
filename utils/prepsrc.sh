#!/bin/bash
set -o errexit
set -o pipefail

thisdir=`pwd`


##########################################
####### download some utilities ##########
##########################################
cd $thisdir/utils/src

if [ ! -f locpy/bin/activate ]; then
    echo; echo "  creating a local python environment..."

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
    
    virtualenv $thisdir/utils/src/locpy  1> /dev/null

    source $thisdir/utils/src/locpy/bin/activate
    pip install --upgrade pip  &>   $thisdir/utils/src/locpy/install_output.txt
    pip install --upgrade distribute &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install cython &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install numpy &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install pandas &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install panda &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install matplotlib &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install seaborn &>>   $thisdir/utils/src/locpy/install_output.txt
    deactivate   
fi

source $thisdir/utils/src/locpy/bin/activate

if [ ! -d  $thisdir/utils/src/poretools ] ; then
    echo " Downloading and installing poretools..."
 
    # used to extract fastq from ont fast5
    cd $thisdir/utils/src/
    git clone https://github.com/arq5x/poretools.git &> /dev/null
    cd poretools/
    git reset --hard 4e04e25f22d03345af97e3d37bd8cf2bdf457fc9   1> /dev/null 
    python setup.py install  &> install_output.txt
fi

if [ ! -d  $thisdir/utils/src/pbh5tools ] ; then
    echo " Downloading and installing pbh5tools..."
    #used to extract fastq from pacbio hdf5 
    cd $thisdir/utils/src
    source $thisdir/utils/src/locpy/bin/activate
    pip install pysam &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install h5py &>>   $thisdir/utils/src/locpy/install_output.txt
    pip install pbcore &>>   $thisdir/utils/src/locpy/install_output.txt
    git clone https://github.com/PacificBiosciences/pbh5tools.git &> /dev/null
    cd pbh5tools
    python setup.py install &> install_output.txt
fi

if [ ! -d  $thisdir/utils/src/fq2fa ] ; then
    echo " Downloading and installing fq2fa..."
    ## fastq 2 fasta
    cd $thisdir/utils/src
    git clone -b nogzstream https://github.com/fg6/fq2fa.git &> /dev/null
    cd fq2fa
    make &> install_output.txt
fi
	
if [ ! -d  $thisdir/utils/src/random_subreads ] ; then
    echo " Downloading and installing random_subreads..."
    ## subsample generator
    cd $thisdir/utils/src
    git clone -b YeastStrainsStudy https://github.com/fg6/random_subreads.git &> /dev/null
fi

if [ ! -d  $thisdir/utils/src/biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu ] ; then
    echo " Downloading biobambam/bamtofastq "
    cd $thisdir/utils/src
    wget https://github.com/gt1/biobambam2/releases/download/2.0.37-release-20160407134604/biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu.tar.gz &> /dev/null
     tar -xvzf biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu.tar.gz > /dev/null
     rm biobambam2-2.0.37-release-20160407134604-x86_64-etch-linux-gnu.tar.gz
fi

if [ ! -f $thisdir/utils/src/pacbiosub/pacbiosub ]; then
	cd $thisdir/utils/src/pacbiosub/
	make
fi

