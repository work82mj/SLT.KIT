#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/:/opt/pv-platform-sample-connector//Linux/lib64/:/opt/lib/cnn/build/lib/:/opt/lib/lamtram/build/lib/
export PYTHONPATH=/opt/lib/NMTGMinor/:/opt/lib/OpenNMT-py/:/opt/subword-nmt/:/usr/local/lib/python


echo $THREADS
if [ -z $THREADS ]; then
export MKL_NUM_THREADS=8
export NUMEXPR_NUM_THREADS=8
export OMP_NUM_THREADS=8
else
export MKL_NUM_THREADS=$THREADS
export NUMEXPR_NUM_THREADS=$THREADS
export OMP_NUM_THREADS=$THREADS
fi

echo $MKL_NUM_THREADS

if [ -z $PORT ]; then
    export PORT=60019
fi

if [ ! -d /logs/ ]; then
    mkdir /logs
fi
S=__$RANDOM$RANDOM$RANDOM__
cat /model/Worker.xml | awk 1 ORS=$S | sed -e  "s|<connection>.*</connection>|<connection> \n \t\t <type> File </type> \n\t\t <inputFile> $INPUTFILE </inputFile> \n\t\t <outputFile> $OUTPUTFILE </outputFile> \n\t </connection>|g" | awk 1 RS=$S > /tmp/Conf.xml

TranslationServer /tmp/Conf.xml

