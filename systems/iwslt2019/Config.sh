#!/bin/bash

PATH="$HOME/opt/bin:$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;



export IWSLTDIR=$WORK/IWSLT2019/

export MOSESDIR=$HOME/opt/mosesdecoder
export BPEDIR=$HOME/opt/subword-nmt
export NMTDIR=$HOME/src/NMTGMinor/
export SLTKITDIR=$HOME/src/slt.kit.private/
export TERDIR=$HOME/opt/tercom-0.7.25/
export BEERDIR=$HOME/opt/beer_2.0/
export CHARACTERDIR=$HOME/opt/CharacTER/
export CTCISL=$HOME/opt/CTC.ISL
export LIUMSPK=$HOME/opt/lium_spkdiarization-8.4.1.jar
export PYTHON3=python3
export SCTKDIR=$HOME/opt/sctk-2.4.10
export NLPDKE=$HOME/src/nlp-dke/
export GPU=0


hostname

module switch intel gcc
module load python/3.6.8
module load cuda/92
module load cudnn/7.4

