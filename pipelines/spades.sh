#!/bin/bash
set -o errexit
set -o pipefail



myexe=$1
strain=$2


thisdir=`pwd`
srcdir=$thisdir/../utils/src

assembler=spades
assembler_info=`echo $assembler version 3.7.1`
wdir=results/spades
exetype='SPADES_vs3.7.1_LOCATION/spades.py'

outdir=$strain
outfile=$assembler\_$strain\_$platform.output



if [ $# -lt 2 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<$assembler\> \<strain\>
	echo "  " $assembler: location of $assembler_info script:  $exetype
	echo "   strain:  s288c, sk1, n44 or cbs. Please notice that for PacBio, only s288c on the 31X  subsample has been run. "
	echo "   Please make sure to have python in your path! (originally ran with python 2.7.10)"  
        exit 1
fi

read1=$thisdir/../fastqs/miseq/$strain\_1.fastq
read2=$thisdir/../fastqs/miseq/$strain\_2.fastq


if [ -z ${myexe-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype; echo
elif [ ! -f ${myexe} ] ; then
	echo; echo "  Usage:"  $0 $exetype 
	echo "  Could not find " $exetype= ${myexe}; echo
	exit 1
fi


if [ -f $read1 ]; then check1=`head -1 $read1`; fi
if [ -f $read2 ]; then check2=`head -1 $read2`; fi

if [ ! -f $read1 ]; then
        echo; echo "  Could not find read-file "  ${read1}; echo
	exit 1
elif [ -z "${check1}" ]; then
        echo; echo "  The read-file "  ${read1} is empty!; echo
	exit 1
fi

if [ ! -f $read2 ]; then
        echo; echo "  Could not find read-file "  ${read2}; echo
	exit 1
elif [ -z "${check2}" ]; then
        echo; echo "  The read-file "  ${read2} is empty!; echo
	exit 1
fi

mkdir -p $wdir/
cd $wdir/

echo; echo  "  Running:" $assembler on  $(basename $read1),$(basename $read2) in folder $wdir/$outdir ; echo 
echo  "  Assembly will be in " $wdir/$outdir/contigs.fasta

python $myexe  --careful --pe1-1 $read1 --pe1-2 $read2  -t 24 -o $outdir  &> $outfile



