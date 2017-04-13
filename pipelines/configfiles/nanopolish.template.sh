

nanopolish_version=NANOP
mybwa=BWA
mysamtools=SAMT

drafta=draft.fa
namefa=s288c_pass2D
reads=$namefa.fasta 
outdir=`pwd`

inpar=5
thr=10



makerange=$nanopolish_version/pipelines/nanopolish_makerange.py
nanomerge=$nanopolish_version/pipelines/nanopolish_merge.py

# Index the draft genome
$mybwa index $drafta

# Align the reads in base space
$mybwa mem -x ont2d -t $thr $drafta $reads | $mysamtools view -Sb - | $mysamtools sort -f - $namefa.sorted.bam
$mysamtools index $namefa.sorted.bam

# Copy the nanopolish model files into the working directory
cp $nanopolish_version/etc/r9-models/* .

# Align the reads in event space
$nanopolish_version/nanopolish eventalign -t $thr --sam -r $reads -b $namefa.sorted.bam -g $drafta --models nanopolish_models.fofn | $mysamtools view -Sb - | $mysamtools sort -f - $namefa.eventalign.sorted.bam

#index alignments
$mysamtools index $namefa.eventalign.sorted.bam

#makerange
python $makerange $drafta  | parallel --results $outdir/nanopolish.results -P $inpar \
    $nanopolish_version/nanopolish variants --consensus polished.{1}.fa -w {1} -r $reads  -b $namefa.sorted.bam -g $drafta -e $namefa.eventalign.sorted.bam -t $thr --min-candidate-frequency 0.1 --models nanopolish_models.fofn

#nanomerge
python $nanomerge polished.*.fa > nanopolished.fa
