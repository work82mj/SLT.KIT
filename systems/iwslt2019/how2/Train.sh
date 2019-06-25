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
#mkdir -p $BASEDIR/data/orig/
#Downlaod Data
#cd $BASEDIR/data/orig/
#mkdir -p parallel
#mkdir -p valid
#cd parallel
#ln -s ../how2-300h-v1/data/train/text.pt how2.t
#ln -s ../how2-300h-v1/data/train/text.en how2.s
#cd ../valid
#ln -s ../how2-300h-v1/data/val/text.pt how2-val.t
#ln -s ../how2-300h-v1/data/val/text.en how2-val.s
#cd ..
#mkdir eval/dev5 -p
#cd eval/dev5
#ln -s ../../how2-300h-v1/data/dev5/text.pt dev5.pt
#ln -s ../../how2-300h-v1/data/dev5/text.en dev5.en

#$SLTKITDIR/scripts/defaultPreprocessor/Train.sh orig prepro

#$SLTKITDIR/scripts/NMTGMinor/Train.sh prepro mt


##############   ASR  #############################
export ENC_LAYER=32
#cd $BASEIDR/data/prepro/train
#ln -s ../../orig/how2-300h-v1/data/train/feats.scp how2.scp
#cd -
#cd $BASEIDR/data/prepro/valid
#ln -s  ../../orig/how2-300h-v1/data/val/feats.scp how2-val.scp
#cd -


#$SLTKITDIR/scripts/NMTGMinor/Train.speech.sh prepro asr s

##############   SLT  #############################
#export ENC_LAYER=32

#$SLTKITDIR/scripts/NMTGMinor/Train.speech.sh prepro slt t


##############   MULTITASK  #############################
#export ENC_LAYER=32
#$SLTKITDIR/scripts/NMTGMinor/Train.multitask.sh prepro slt+mt t


for tst in dev5
do

#$SLTKITDIR/scripts/defaultPreprocessor/Translate.sh $tst prepro
#$SLTKITDIR/scripts/NMTGMinor/Translate.sh manualTranscript.$tst prepro mt
# ~/.local/bin/nmtpy-coco-metrics $BASEDIR/data/mt/eval/manualTranscript.$tst.pt -r $BASEDIR/data/prepro/eval/manualTranscript.$tst.pt

$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro asr
$SLTKITDIR/scripts/NMTGMinor/Translate.speech.sh $tst prepro slt
$SLTKITDIR/scripts/NMTGMinor/Translate.sh $tst asr mt

done
