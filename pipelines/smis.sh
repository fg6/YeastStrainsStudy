#!/bin/bash
set -o errexit
set -o pipefail



strain=$1
platform=$2




thisdir=`pwd`
srcdir=$thisdir/../utils/src

assembler=$thisdir/../utils/src/smis
wdir=results/smis

outdir=$strain\_$platform
outfile=$assembler\_$strain\_$platform.output



if [ $# -lt 2 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<strain\> \<platform\>
	echo "   strain:  s288c, sk1, n44 or cbs. Please notice that for PacBio, only s288c on the 31X  subsample has been run. "
	echo "   platform: ont or pacbio "
	echo; echo "   Please make sure you have run 'spades.sh /full/path/to/spades <strain> <platform>'  before running smis!"
        exit 1
fi


inputfa=$thisdir/results/spades/$strain\_miseq/contigs.fasta

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

if [ ! -d ${myexe} ] ; then
	echo "  Could not find folder for smis:" ${myexe};
	echo "  Please download smis from Github: https://github.com/fg6/smis "; echo
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

	echo; echo  "  Running:" $assembler on  $(basename $reads) in folder $wdir/$outdir ; echo 
	echo  "  Assembly will be in " $wdir/$outdir/spinner_scaffolds.fasta 
	

	$myexe/setup.sh $thisdir/$wdir/$outdir/ $inputfa $reads > /dev/null
	cd $thisdir/$wdir/$outdir/
	./mysmissv.sh  &> $outfile
fi

