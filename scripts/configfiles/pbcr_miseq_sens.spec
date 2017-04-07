#following from http://www.cbcb.umd.edu/software/PBcR/mhap/

merSize=16
#mhap=-k 16 --num-hashes 512 --num-min-matches 3 --threshold 0.04 --weighted

frgCorrThreads = 10


useGrid=0
scriptOnGrid=0


#  
ovlMemory=50
ovlStoreMemory=100000
threads=20

ovlConcurrency=1
cnsConcurrency=8
merylThreads=32
merylMemory=32000
#ovlRefBlockSize=20000
frgCorrBatchSize = 100000
ovlCorrBatchSize = 100000


# from pbcr_oxford: adjust assembly parameters to overlap at high error rate since the corrected reads are not 99% like pacbio
# lower QV of corrected sequences from 99+ to 97-98
QV=52

asmOvlErrorRate = 0.1
asmUtgErrorRate = 0.06
asmCgwErrorRate = 0.1
asmCnsErrorRate = 0.1
asmOBT=1
batOptions=-RS -CS
utgGraphErrorRate = 0.05
utgMergeErrorRate = 0.05
asmObtErrorRate=0.08
asmObtErrorLimit=4.5
# from http://wgs-assembler.sourceforge.net/wiki/index.php/PBcR#Low_Coverage_Assembly

