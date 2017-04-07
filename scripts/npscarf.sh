#!/bin/bash
set -o errexit
set -o pipefail



myexe=$1
strain=$2
platform=$3
mybwa=$4



thisdir=`pwd`
srcdir=$thisdir/../src

assembler=npscarf
assembler_info=`echo $assembler version  1.6-08a`
wdir=results/npscarf
exetype='npscarf_vs1.6-08a_FOLDER/'

outdir=$strain\_$platform
outfile=$assembler.output


if [ $# -lt 4 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<$assembler\> \<strain\> \<platform\>  \<bwa\>
	echo "  " $assembler: location of $assembler_info script:  $exetype
	echo "   strain:  s288c, sk1, n44 or cbs. Please notice that for PacBio, only s288c on the 31X  subsample has been run. "
	echo "   platform: ont or pacbio "
        echo "   bwa: location of bwa"
	echo; echo "   Please make sure you have run 'spades.sh /full/path/to/spades <strain> <platform> '  before running npscarf!"
        exit 1
fi

inputfa=$thisdir/results/spades/$strain\_miseq/contigs.fasta

if [ $platform == 'ont' ]; then
        reads=$thisdir/../fastqs/ont/$strain\_pass2D.fastq

else
        echo pacbio
        if [ $strain == 's288c' ]; then	
	    reads=$thisdir/../fastqs/pacbio/s288c_pacbio_ontemu_31X.fastq
	    outdir=$outdir\_31X_ONTemu			
            echo; echo "   For pacbio s288c running the subsample with '31X' coverage"; echo
	else
            reads=$thisdir/../fastqs/pacbio/$strain\_pacbio.fastq    
            echo; echo "   Scaffolding using the whole pacbio data is possible but time consuming."
	    echo; echo "   This has not been done in the paper, so I will stop now, delete or comment line:" $(($LINENO+1)) 
	    exit 1
	fi	
fi

if [ -z ${myexe-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype; echo
elif [ ! -d ${myexe} ] ; then
	echo "  Could not find npscarf folder " ${myexe}; echo
	exit 1
fi

if [ -f $reads ]; then check=`head -1 $reads`; fi
if [ ! -f $reads ]; then
        echo; echo "  Could not find read-file "  ${reads}; echo
	exit 1
elif [ -z "${check}" ]; then
        echo; echo "  The read-file "  ${reads} is empty!; echo
	exit 1
fi

if [ -f $inputfa ]; then check=`head -1 $inputfa`; fi

if [ ! -f $inputfa ]; then
        echo; echo "  Could not find read-file "  ${inputfa}; echo
	exit 1
elif [ -z "${check}" ]; then
        echo; echo "  The read-file "  ${inputfa} is empty!; echo
else
        mkdir -p $wdir/$outdir
	cd $wdir/$outdir

	echo; echo  "  Running:" $assembler on  $(basename $reads) in folder $wdir/$outdir ; echo 
	echo  "  Assembly will be in " $wdir/$outdir/npScarf.fin.fasta
	

	$myexe/jsa.seq.sort -r -n --input $inputfa --output sort_spades.fasta 
	$mybwa index sort_spades.fasta
	$mybwa mem -t 10  -x ont2d  -a -Y sort_spades.fasta $reads  | $myexe/jsa.np.gapcloser -b - -seq sort_spades.fasta  --verbose --prefix=npScarf   	
fi

