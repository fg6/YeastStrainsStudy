#!/bin/bash
set -o errexit
set -o pipefail



myexe1=$1
myexe2=$2
strain=$3
platform=$4
cov=$5


thisdir=`pwd`
srcdir=$thisdir/../utils/src

assembler=miniasm
assembler_info=`echo  minimap r122 and miniasm r104`
wdir=results/miniasm
exetype1='MINIMAP_vsr122_LOCATION/minimap'
exetype2='MINIASM_vsr104_LOCATION/miniasm'

outdir=$strain\_$platform
outfile=$assembler\_$strain\_$platform.output



if [ $# -lt 4 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<minimap\> \<miniasm\> \<strain\> \<platform\>  \<cov\>
	echo "  minimap:" location for minimap:  $exetype1
	echo "  miniasm:" location for miniasm:  $exetype2
	echo "   strain:  s288c, sk1, n44 or cbs (please notice that because of low depth only s288c has been assembled for ONT data)"
	echo "   platform: ont or pacbio "
	echo "   cov: only for pacbio s288c: choose coverage sample '31X' or 'allX' "

        exit 1
fi


if [ $platform == 'ont' ]; then
	reads=$thisdir/../fastqs/ont/$strain/$strain\_pass2D.fastq
	if [ ! -z ${cov-x} ] && [ $cov == 'allX' ]; then
        	echo 'allX option valid for pacbio s288c only!'
        	exit 1
        fi              
	
	if [ $strain != 's288c' ]; then
		echo; echo '  Warning!! Probably read depth not enough for denovo assembly with' $assembler for $strain ' ONT data'
	fi

else

	if [ $strain == 's288c' ] && [ -z ${cov-x} ]; then
		echo; echo "  For pacbio s288c you should choose if running the sample with all data (allX) or the subsample with '31X' coverage"; echo
	       	echo; echo "  Usage:" $(basename $0) \<$assembler\> \<strain\> \<platform\>  \<cov\>
	        echo "  " $assembler: location of $assembler_info script:  $exetype
        	echo "   strain:  s288c, sk1, n44 or cbs (please notice that because of low depth only s288c has been assembled for ONT data)"
       		echo "   platform: ont or pacbio "
        	echo "   cov: only for pacbio s288c: choose coverage sample '31X' or 'allX' " 
		exit 1
	fi

        if  [ ! -z ${cov-x} ]; then
                if [ $cov == '31X' ] && [ $strain != 's288c' ]; then 
                        echo '31X option valid for pacbio s288c only!'
                        exit 1
                elif [ $cov == '31X' ] && [ $strain == 's288c' ]; then	
	        	reads=$thisdir/../fastqs/pacbio/s288c/s288c_pacbio_ontemu_31X.fastq
			outdir=$outdir\_31X_ONTemu			
		else
                	reads=$thisdir/../fastqs/pacbio/$strain/$strain\_pacbio.fastq               	
		fi	
	else	
		if [ $strain == 's288c' ]; then
                	echo; echo "For pacbio s288c you should choose if running the sample with all data (allX) or the subsample with '31X' coverage"; echo
                	echo; echo "  Usage:" $(basename $0) \<$assembler\> \<strain\> \<platform\>  \<cov\>
                	echo "   cov: only for pacbio s288c: choose coverage sample '31X' or 'allX' "
                	exit 1
        	else
                	reads=$thisdir/../fastqs/pacbio/$strain/$strain\_pacbio.fastq                        
		fi

	fi

fi

if [ -z ${myexe1-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype1; echo
elif [ ! -f ${myexe1} ] ; then
	echo; echo "  Usage:"  $0 $exetype1 
	echo "  Could not find " $exetype1= ${myexe1}; echo
	exit 1
fi

if [ -z ${myexe2-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype2; echo
elif [ ! -f ${myexe2} ] ; then
	echo; echo "  Usage:"  $0 $exetype2
	echo "  Could not find " $exetype2= ${myexe2}; echo
	exit 1
fi


if [ -f $reads ]; then check=`head -1 $reads`; fi
if [ ! -f $reads ]; then
        echo; echo "  Could not find read-file "  ${reads}; echo
elif [ -z "${check}" ]; then
        echo; echo "  The read-file "  ${reads} is empty!; echo
else
    mkdir -p $wdir/$outdir
    cd $wdir/$outdir
  
    echo; echo  "  Running:" $assembler on  $(basename $reads) in folder $wdir/$outdir ; echo 
    echo  "  Assembly will be in" $wdir/$outdir/assembly.fa; echo
    $myexe1 -Sw5 -L100 -m0 -t8 $reads $reads  | gzip -1 > reads.paf.gz   &> $outfile
    $myexe2 -f $reads reads.paf.gz > reads.gfa   &>> $outfile
    cat reads.gfa | egrep "^S" | awk '{print ">" $2"\n"$3}' > assembly.fa

fi

