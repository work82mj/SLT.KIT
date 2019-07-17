#!/bin/bash


source ../Config.sh

export systemName=how2
export sl=en
export tl=pt


export BASEDIR=$IWSLTDIR/how2/
export BPESIZE=10000

export LAYER=12
export TRANSFORMER=stochastic_transformer

echo $BASEDIR



##############   MT   #############################
mkdir -p $BASEDIR/data/orig/
#Downlaod Data
cd $BASEDIR/data/orig/
mkdir -p parallel
mkdir -p valid
cd parallel
ln -s ../how2-300h-v1/data/train/text.pt how2.t
ln -s ../how2-300h-v1/data/train/text.en how2.s
cd ../valid
ln -s ../how2-300h-v1/data/val/text.pt how2-val.t
ln -s ../how2-300h-v1/data/val/text.en how2-val.s
cd ..
mkdir eval/dev5 -p
cd eval/dev5
ln -s ../../how2-300h-v1/data/dev5/text.pt dev5.pt
ln -s ../../how2-300h-v1/data/dev5/text.en dev5.en

$SLTKITDIR/scripts/defaultPreprocessor/Train.sh orig prepro

$SLTKITDIR/scripts/NMTGMinor/Train.sh prepro mt


##############   ASR  #############################
export ENC_LAYER=32
cd $BASEIDR/data/prepro/train
ln -s ../../orig/how2-300h-v1/data/train/feats.scp how2.scp
cd -
cd $BASEIDR/data/prepro/valid
ln -s  ../../orig/how2-300h-v1/data/val/feats.scp how2-val.scp
cd -

$SLTKITDIR/scripts/NMTGMinor/Train.speech.sh prepro asr s
$SLTKITDIR/scripts/NMTGMinor/Cont.speech.sh prepro asr asr.cont s

##############   SLT  #############################
export ENC_LAYER=32

$SLTKITDIR/scripts/NMTGMinor/Train.speech.sh prepro slt t
$SLTKITDIR/scripts/NMTGMinor/Cont.speech.sh prepro slt slt.cont t
$SLTKITDIR/scripts/NMTGMinor/Cont.speech.sh prepro slt.cont slt.cont2 t


for tst in dev5
do

$SLTKITDIR/scripts/defaultPreprocessor/Translate.sh $tst prepro
$SLTKITDIR/scripts/NMTGMinor/Translate.sh manualTranscript.$tst prepro mt

$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro asr
$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro asr.cont
cp $BASEDIR/data/asr/eval/dev5.t $BASEDIR/data/asr/eval/dev5.s
$SLTKITDIR/scripts/NMTGMinor/Translate.sh $tst asr mt
cp $BASEDIR/data/asr.cont/eval/dev5.t $BASEDIR/data/asr.cont/eval/cont.dev5.s
$SLTKITDIR/scripts/NMTGMinor/Translate.sh cont.$tst asr.cont mt


$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro slt



export BEAMSIZE=8
$SLTKITDIR/scripts/NMTGMinor/Translate.sh manualTranscript.$tst prepro mt

$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro asr
$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro asr.cont
cp $BASEDIR/data/asr/eval/dev5.beam$BEAMSIZE.t $BASEDIR/data/asr/eval/dev5.beam$BEAMSIZE.s
$SLTKITDIR/scripts/NMTGMinor/Translate.sh $tst.beam$BEAMSIZE asr mt
cp $BASEDIR/data/asr.cont/eval/dev5.beam$BEAMSIZE.t $BASEDIR/data/asr.cont/eval/cont.dev5.beam$BEAMSIZE.s
$SLTKITDIR/scripts/NMTGMinor/Translate.sh cont.$tst.beam$BEAMSIZE asr.cont mt


$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro slt
$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro slt.cont
$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro slt.cont2


for beam in .beam8. .
do

sed -e "s/@@ //g" $BASEDIR/data/mt/eval/manualTranscript.${tst}${beam}t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > $BASEDIR/data/mt/eval/manualTranscript.${tst}${beam}pt

 ~/.local/bin/nmtpy-coco-metrics $BASEDIR/data/mt/eval/manualTranscript.${tst}${beam}pt -r $BASEDIR/data/prepro/eval/manualTranscript.$tst.pt

for out in mt slt slt.cont
do

if [ "$beam" == ".beam8." ] && [ "$out" == "mt" ]; then
beam=.beam8.beam8.
fi
echo $beam
sed -e "s/@@ //g" $BASEDIR/data/$out/eval/${tst}${beam}t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > $BASEDIR/data/$out/eval/${tst}${beam}pt

 ~/.local/bin/nmtpy-coco-metrics $BASEDIR/data/$out/eval/${tst}${beam}pt -r $BASEDIR/data/prepro/eval/manualTranscript.$tst.pt

if [ "$out" == "mt" ]; then

sed -e "s/@@ //g" $BASEDIR/data/$out/eval/cont.${tst}${beam}t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > $BASEDIR/data/$out/eval/cont.${tst}${beam}pt

 ~/.local/bin/nmtpy-coco-metrics $BASEDIR/data/$out/eval/cont.${tst}${beam}pt -r $BASEDIR/data/prepro/eval/manualTranscript.$tst.pt


fi

done


###Eval ASR

for asr in asr asr.cont
do
 sed -e "s/@@ //g"  $BASEDIR/data/$asr/eval/${tst}${beam}t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | sed -e "s/ '/'/g" | sed -e "s/\.//" -e "s/,//g" -e "s/\!//g" -e "s/?//g" |  perl -nle 'print lc' >  $BASEDIR/data/$asr/eval/${tst}${beam}asr
awk '{print $NF}' /home/dx294494/opt/how2-dataset/eval/asr/hyp.filtered.word.wer.r9216e.max150.dev5.beam10.sclite | paste $BASEDIR/data/$asr/eval/${tst}${beam}asr - > $BASEDIR/data/$asr/eval/${tst}${beam}sclite
echo "Model $asr Beam $beam"

~/opt/sctk-2.4.10/bin/sclite  -r  $BASEDIR/data/orig/eval/dev5/dev5.filtered.en -h  $BASEDIR/data/$asr/eval/${tst}${beam}sclite -i spu_id -f 0 -o sum stdout dtl pra | grep Sum/Avg | awk '{print $11}'
done



done



done
