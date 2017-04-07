thisdir=`pwd`

#### download some utilities
mkdir -p $thisdir/src

## fastq 2 fasta
cd $thisdir/src
git clone -b nogzstream https://github.com/fg6/fq2fa.git
cd fq2fa
make

cd $thisdir/src
git clone -b YeastStrainsStudy https://github.com/fg6/random_subreads.git


#### download data (fastq-read files)
# get data
#tar -xvzf fastqs.tar.gz

#### download final assemblies
# get assemblies
#tar -xvzf assemblies.tar.gz




