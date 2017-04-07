

sed -e 's#ontdata_fastq#fastqs/ont#g' $1 | sed -e 's#pacbio_fastq#fastqs/pacbio#g' | sed -e 's#miseq_fastq#fastqs/miseq#g' > temp && mv temp $1 

grep fastq $1
