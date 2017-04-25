#!/bin/bash
#set -o errexit
#set -o pipefail

thisdir=`pwd`

strain=$1
assembler=$2
platform1=$3
platform2=$4



folder=$thisdir/final_fastas
mkdir -p $folder
cd $folder


if [ ! -d YeastAssemblies ]; then  
    echo "  Cannot find the folder final_fastas/YeastAssemblies"
    echo "  Downloading the final assemblies first..."
    cd $thisdir
    ./launchme.sh finalfastas
fi



if [ -d YeastAssemblies ]; then  
    cd YeastAssemblies
    sumfile=Summary_of_assemblies.txt
    #echo "   " or: ./launchme.sh find_assembly <strain> <assembler> <platform1> <platform2>
  
    echo "  which strain? [s288c]"; read strain
    if [[ $strain == "" ]]; then strain='s288c'; fi
    #echo "   strain=["$strain"]"
    echo "  which assembler? [canu] (any,abruijn,canu,pbcr,miniasm,racon,smartdenovo,npscarf,smis,spades,hybridspades,nanopolish"; read assembler
    if [[ $assembler == "" ]]; then assembler='canu'; fi
    echo "  platform ? [ont] (any, ont, pacbio, miseq)"; read platform1
    if [[ $platform1 == "" ]]; then platform1=ont; fi
   

    if [[ $assembler == "any" ]] &&  [[ $platform1 == "any" ]]; then
	found=`grep $strain $sumfile | wc -l`
    elif [[ $assembler == "any" ]]; then
	found=`grep $strain $sumfile | grep $platform1 | wc -l`
    elif [[ $platform1 == "any" ]]; then
	found=`grep $strain $sumfile | grep $assembler | wc -l`
    else
	found=`grep $strain $sumfile | grep $assembler | grep $platform1 | wc -l`
    fi
 
    if [[ $found > 0 ]]; then
	echo; echo; echo "     **** There is(are)" $found "assembly(ies) satisfying your criteria: ****"
	
	#if [[ $assembler == "any" ]]; then
	#    list=( $(find * | grep $strain  | grep $platform1 ) );
	#else
	#    list=( $(find * | grep $strain  | grep $assembler  | grep $platform1 ) );
	#fi
	
	#echo;echo "       Assembly_name,                                    strain, Assembler, Platform(s), Sample_type(s)"
	#for assembly in  "${list[@]}"; do
	#    this=`grep $assembly $sumfile`
	#    echo "   final_fastas/YeastAssemblies/"$this
	#done

	
	list=( $(find *.fasta ) );
	ii=0
	for assembly in "${list[@]}"; do
            this=`echo $assembly | grep $strain | wc -l`
	    if [[ $this > 0 ]]; then
		req=$assembly

		if [[ $assembler != "any" ]]; then
		    isok=`echo $req |  grep $assembler | wc -l`
		    req=`echo $req |  grep $assembler `
		
		else
		    isok=1
		fi
		if [[ $isok > 0 ]]; then
		    if [[ $platform1 != "any" ]]; then
			isok=`echo $req |  grep $platform1 | wc -l`
			req=`echo $req |  grep $platform1 `
		    fi		    	
		fi
		if [[ $isok > 0 ]]; then 

		    if [[ $ii == 0 ]]; then
			echo; echo "    ******************************************************************************************************"
			echo "       Assembly_name,                                    strain, Assembler, Platform(s), Sample_type(s)";echo
		    fi
		    this=`grep $assembly $sumfile`
		    echo "   final_fastas/YeastAssemblies/"$this
		
		    ii=$(($ii+1))

		fi

	    fi

	done


	echo
    else
	echo; echo "  Sorry there are no assemblies satisfying your criteria!"; echo
    fi
    
else
    echo "    There were errors during the download, cannot find assemblies...try again"; echo
fi