#!/bin/bash

input=$1
name=$2

language=$3

size=512
if [ $# -ne 3 ]; then
    size=$4
fi
innersize=$((size*4))

if [ -z $LAYER ]; then
    LAYER=8
fi

if [ -z $ENC_LAYER ]; then
    ENC_LAYER=$LAYER
fi

if [ -z $TRANSFORMER ]; then
    TRANSFORMER=transformer
fi


if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$NMTDIR" ]; then
    NMTDIR=/opt/NMTGMinor/
fi

if [ -z "$GPU" ]; then
    GPU=0
fi

if [ $GPU -eq -1 ]; then
    gpu_string_train=""
    gpu_string_avg=""
else
    gpu_string_train="-gpus "$GPU
    gpu_string_avg="-gpu "$GPU
fi

if [ ! -z "$FP16" ]; then
    gpu_string_train=$gpu_string_train" -fp16"
fi


if [ -z $OPTIM ]; then
    optim_str="-optim adam -update_method noam"
elif [ $OPTIM == "noam" ]; then
    optim_str="-optim adam -update_method noam"
elif [ $OPTIM == "adam" ]; then
    optim_str="-optim adam"
else 
    echo "Unkown optim methods "$OPTIM
    exit;
fi


if [ -z "$LR" ]; then
    LR=2
fi

if [ -z "$ASR_FORMAT" ]; then
    ASR_FORMAT=scp
fi

if [ -z "$ASR_FEATURE_SIZE" ]; then
    ASR_FEATURE_SIZE=43
fi

asr_input_size=`echo $ASR_FEATURE_SIZE | awk '{print 4*$1}'`


mkdir -p $BASEDIR/tmp/${name}/
mkdir -p $BASEDIR/model/${name}/
mkdir -p $BASEDIR/model/${name}/checkpoints/




for l in $ASR_FORMAT $language
do
    for set in train valid
    do
	echo $l $set
       if [ $l == "h5" ]; then
	   #h5 does not support mutliple files
	   echo START
	   if [ -f "$BASEDIR/tmp/${name}/$set.$ASR_FORMAT" ]; then
	       rm $BASEDIR/tmp/${name}/$set.$ASR_FORMAT
	   fi
	   echo DELETED
	   echo ls $BASEDIR/data/${input}/${set}/*\.${l} -l
	   files=`ls $BASEDIR/data/${input}/${set}/*\.${l} -l | wc -l`
	   echo $files
	   if [ $files -ne 1 ]; then
	       echo "H5 only support a single training file"
	       exit;
	   fi
	   ln -s $BASEDIR/data/${input}/${set}/*\.${l} $BASEDIR/tmp/${name}/$set.$l
       else
	   echo -n "" > $BASEDIR/tmp/${name}/$set.$l
	   for f in $BASEDIR/data/${input}/${set}/*\.${l}
	   do
	       
 	   cat $f >> $BASEDIR/tmp/${name}/$set.$l
	   done
       fi

    done
done

python3 $NMTDIR/preprocess.py \
        -train_src $BASEDIR/tmp/${name}/train.$ASR_FORMAT \
        -train_tgt $BASEDIR/tmp/${name}/train.$language \
       -valid_src $BASEDIR/tmp/${name}/valid.$ASR_FORMAT \
       -valid_tgt $BASEDIR/tmp/${name}/valid.$language \
       -src_seq_length 1024 \
       -tgt_seq_length 512 \
       -concat 4 -asr -src_type audio\
       -asr_format $ASR_FORMAT\
       -save_data $BASEDIR/model/${name}/train

python3 -u $NMTDIR/train.py  -data $BASEDIR/model/${name}/train -data_format raw \
       -save_model $BASEDIR/model/${name}/checkpoints/model \
       -model $TRANSFORMER \
       -batch_size_words 2048 \
       -batch_size_update 24568 \
       -batch_size_sents 9999 \
       -batch_size_multiplier 8 \
       -encoder_type audio \
       -checkpointing 0 \
       -input_size $asr_input_size \
       -layers $LAYER \
       -encoder_layer $ENC_LAYER \
       -death_rate 0.5 \
       -model_size $size \
       -inner_size $innersize \
       -n_heads 8 \
       -dropout 0.2 \
       -attn_dropout 0.2 \
       -word_dropout 0.1 \
       -emb_dropout 0.2 \
       -label_smoothing 0.1 \
       -epochs 64 \
       $optim_string \
       -learning_rate $LR \
       -normalize_gradient \
       -warmup_steps 8000 \
       -max_generator_batches 8192 \
       -tie_weights \
       -seed 8877 \
       -log_interval 1000 \
       $gpu_string_train &> $BASEDIR/model/${name}/train.log


checkpoints=""

for f in `ls $BASEDIR/model/${name}/checkpoints/model_ppl_*`
do
    checkpoints=$checkpoints"${f}|"
done
checkpoints=`echo $checkpoints | sed -e "s/|$//g"`


python3 -u $NMTDIR/average_checkpoints.py $gpu_string_avg \
                                    -models $checkpoints \
                                    -output $BASEDIR/model/${name}/model.pt

rm -r $BASEDIR/tmp/${name}/
