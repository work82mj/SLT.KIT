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


mkdir -p $BASEDIR/data/orig/
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

#$SLTKITDIR/scripts/defaultPreprocessor/Train.sh orig prepro

$SLTKITDIR/scripts/NMTGMinor/Train.sh prepro mt
