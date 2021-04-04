#!/bin/bash

cuda=`echo $1 | sed -e "s/\.//g"`
# /opt/miniconda3/bin/pip install http://download.pytorch.org/whl/cu${cuda}/torch-0.4.0-cp36-cp36m-linux_x86_64.whl
/opt/anaconda3/bin/pip install https://download.pytorch.org/whl/cu91/torch-0.4.0-cp36-cp36m-linux_x86_64.whl