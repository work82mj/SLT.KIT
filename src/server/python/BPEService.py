#!/usr/bin/env python
# -*- coding: utf-8 -*-


import codecs

from apply_bpe import BPE

def decode_(line):
    if hasattr(line, "decode"):
	return line.decode("utf-8")
    else:
	return line

def encode_(line):
    if hasattr(line, "encode"):
	return line.encode("utf-8")
    else:
	return line

class BPEService(object):

    def __init__(self,codes):
        self.bpe = BPE(codecs.open(codes,encoding='utf-8'))

    def process_line(self,line):
        return encode_(self.bpe.process_line(decode_(line)))
        #return self.bpe.process_line(line.decode("UTF-8")).encode("UTF-8")
