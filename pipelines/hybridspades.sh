#!/bin/bash
set -o errexit
set -o pipefail



myexe=$1
strain=$2
platform=$3


thisdir=`pwd`
srcdir=$thisdir/../src

assembler=spades
assembler_info=`echo $assembler version 3.7.1`
wdir=results/hybridspades 
exetype='HYBRIDSPADES_vs1.0_LOCATION/spades.py'

outdir=$strain\_$platform
outfile=$assembler.output


if [ $# -lt 3 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<$assembler\> \<strain\> \<platform\>  
	echo "  " $assembler: location of $assembler_info script:  $exetype
	echo "   strain:  s288c, sk1, n44 or cbs. Please notice that for PacBio, only s288c on the 31X  subsample has been run. "
	echo "   platform: ont or pacbio "

        exit 1
fi

read1=$thisdir/../fastqs/miseq/$strain/$strain\_1.fastq
read2=$thisdir/../fastqs/miseq/$strain/$strain\_2.fastq

if [ $platform == 'ont' ]; then
	reads=$thisdir/../fastqs/ont/$strain/$strain\_pass2D.fastq
else
        if [ $strain == 's288c' ]; then 
            reads=$thisdir/../fastqs/pacbio/$strain/s288c_pacbio_ontemu_31X.fastq
            outdir=$outdir\_31X_ONTemu                  
            echo; echo "   For pacbio s288c running the subsample with '31X' coverage"; echo
        else
            reads=$thisdir/../fastqs/pacbio/$strain/$strain\_pacbio.fastq    
            echo; echo "   Scaffolding using the whole pacbio data is possible but time consuming."
            echo; echo "   This has not been done in the paper, so I will stop now, delete or comment line:" $(($LINENO+1)) 
            exit 1
        fi     
fi

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

echo; echo  "  Running:" $assembler on  $(basename $read1),$(basename $read2) and $reads in folder $wdir/$outdir ; echo 
echo  "  Assembly will be in " $wdir/$outdir/contigs.fasta

python $myexe  --careful --pe1-1 $read1 --pe1-2 $read2  --nanopore $reads -t 24 -o $outdir
