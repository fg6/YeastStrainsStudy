#following from http://www.cbcb.umd.edu/software/PBcR/mhap/

merSize=16
mhap=-k 16 --num-hashes 512 --num-min-matches 3 --threshold 0.04 --weighted

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
ovlRefBlockSize=20000
frgCorrBatchSize = 100000
ovlCorrBatchSize = 100000


sgeScript = -pe threads 1
sgeConsensus = -pe threads 8
sgeOverlap = -pe threads 10 –l mem=2GB
sgeCorrection = -pe threads 10 –l mem=2GB
sgeFragmentCorrection = -pe threads 10 –l mem=2GB
sgeOverlapCorrection = -pe threads 1 –l mem=16GB

