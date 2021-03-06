#!/bin/bash
set -o errexit
set -o pipefail



mynanopolish=$1
mysamtools=$2
mybwa=$3


strain=s288c
platform=ont


assembler=nanopolish
assembler_info=`echo $assembler version 0.5.0`
wdir=results/nanopolish_on_canu_s288c_ont
exetype='NANOPOLISH_vs_0.5.0_FOLDER/'

thisdir=`pwd`
srcdir=$thisdir/../utils/src

if [ $# -lt 3 ]  || [ $1 == '-h' ]; then
        echo; echo "  Runs nanpolish on the s288c ont pass2D Canu assembly"
	echo "  Usage:" $(basename $0) \<$assembler\> \<samtools\> \<bwa\> \<fast5dir\>
	echo "  " $assembler: location of $assembler_info folder:  $exetype
	echo "  " samtools: location of samtools
	echo "  " bwa: location of bwa
	echo ; echo "  Warning: please notice that nanopolish needs the original MinION fast5 file. "
	echo "  If you deleted them, you need to re-download them with the launchme.sh script"
	
        exit 1
fi


if [ -z ${nanopolish_version-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype; echo
elif [ ! -d ${nanopolish_version} ] ; then
	echo; echo "  Usage:"  $0 $exetype 
	echo "  Could not find " $exetype= ${nanopolish_version}; echo
	exit 1
fi

fast5dir=$thisdir/../fastqs/ont/$strain
reads=$thisdir/../fastqs/ont/$strain/$strain\_pass2D.fastq
drafta=$thisdir/results/canu/$strain\_ont/$strain.contigs.fasta



if [ ! -f $drafta ]; then
    echo; echo "  The Canu assembly $drafta not found! "
    echo "  This nanopolish script needs the s288c ont Canu assembly! "
    echo "  Please, before $0, run:"; echo "    ./canu.sh /full/path/to/canu s288c ont "
    exit 1
else
    check=`head -1 $drafta`
    if [ -z "${check}" ]; then
        echo; echo "  The read-file "  ${reads} is empty!; echo
	exit 1
    fi
fi

if [ -f $reads ]; then check=`head -1 $reads`; fi
if [ ! -f $reads ]; then
        echo; echo "  Could not find read-file "  ${reads}; echo
elif [ -z "${check}" ]; then
        echo; echo "  The read-file "  ${reads} is empty!; echo
else
    	mkdir -p $wdir
	cd $wdir
	readsfa=$(basename $reads .fastq).fasta
        if [ ! -f $readsfa ]; then
                echo "Nanopolish needs a fasta file...creating it now.."
                $srcdir/fq2fa/fq2fa $reads 0
		tt="s#/lustre/scratch110/sanger/ont#$fast5dir#g"
		sed -e $tt $readsfa | sed -e 's#:# #g' > temp.fa
		mv temp.fa $readsfa 		
        fi
	ln -sf $drafta draft.fa


	ch1="s#SAMT#$mysamtools#g"
	ch2="s#BWA#$mybwa#g"
	ch3="s#NANOP#$mynanopolish#g"

	

	sed -e $ch1 $thisdir/configfiles/nanopolish.template.sh | \
	    sed -e $ch2 | sed -e $ch3 > runnanopolish.sh
	
	echo; echo "  "The script to launch nanopolish is ready: $wdir/runnanopolish.sh
	echo "  "To launch on local machine, simply do:
	echo "    $" cd $wdir
	echo "    $" ./runnanopolish.sh
	echo "  "But Warning!! 
	echo "  "nanopolish requires days of running, 
	echo "  "please consider running the script $wdir/runnanopolish.sh on a farm !
	echo; echo "  If no errors, assembly will be in" $wdir/nanopolished.fa ; echo       
fi

