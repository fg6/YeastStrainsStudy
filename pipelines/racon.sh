#!/bin/bash
set -o errexit
set -o pipefail



myexe1=$1
myexe2=$2
myexe3=$3
strain=$4
platform=$5
cov=$6


thisdir=`pwd`
srcdir=$thisdir/../utils/src

assembler=racon
assembler_info=`echo racon github commit 28980bec3e98189853ed919764d5a8a9e6291264`
wdir=results/racon
exetype1='MINIMAP_vsr122_LOCATION/minimap'
exetype2='MINIASM_vsr104_LOCATION/miniasm'
exetype3='RACON_FOLDER/'

outdir=$strain\_$platform
outfile=$assembler.output


if [ $# -lt 5 ]  || [ $1 == '-h' ]; then
	echo; echo "  Usage:" $(basename $0) \<minimap\> \<miniasm\> \<racon\> \<strain\> \<platform\>  \<cov\>
	echo "  minimap:" location for minimap:  $exetype1
	echo "  miniasm:" location for miniasm:  $exetype2
	echo "  racon:" location for racon:  $exetype3
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
	        	reads=$thisdir/../fastqs/pacbio/$strain/s288c_pacbio_ontemu_31X.fastq
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
if [ -z ${myexe3-x} ]; then 
	echo ; echo "  Usage:"  $0 $exetype3; echo
elif [ ! -d ${myexe3} ] ; then
	echo; echo "  Usage:"  $0 $exetype3
	echo "  Could not find " $exetype3= ${myexe3}; echo
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
    echo  "  Assembly will be in" $wdir/$outdir/results/consensus-iter2.fasta; echo

    # miniasm assembly first:
    echo; echo "  Running minimap/miniasm .."
    #$myexe1 -Sw5 -L100 -m0 -t8 $reads $reads  | gzip -1 > reads.paf.gz 
    #$myexe2 -f $reads reads.paf.gz > reads.gfa
    #awk '$1 ~/S/ {print ">"$2"\n"$3}' reads.gfa > layout_miniasm.fasta


    threads=4

    mkdir -p results/temp
    mkdir -p temp
    ##### Racon: first iteration
    echo; echo "  Racon first iteration .."
    contigs=layout_miniasm.fasta
    sam=results/temp/consensus-iter1.sam
    consensus=results/consensus-iter1.fasta

    $myexe3/tools/graphmap/bin/Linux-x64/graphmap align -a anchor --rebuild-index -B 0 -r ${contigs} -d ${reads} -o ${sam} --extcigar -t ${threads}  &> $outfile
    $myexe3/bin/racon -M 5 -X -4 -G -8 -E -6 --bq 10 -t ${threads} ${contigs} ${sam} ${consensus}  &>> $outfile


    ##### Racon: second iteration
    echo; echo "  Racon second iteration .."
    contigs=results/consensus-iter1.fasta
    sam=results/temp/consensus-iter2.sam
    consensus=results/consensus-iter2.fasta

    $myexe3/tools/graphmap/bin/Linux-x64/graphmap align -a anchor --rebuild-index -B 0 -r ${contigs} -d ${reads} -o ${sam} --extcigar -t ${threads}  &>> $outfile
    $myexe3/bin/racon -M 5 -X -4 -G -8 -E -6 --bq 10 -t ${threads} ${contigs} ${sam} ${consensus} &>> $outfile

fi

