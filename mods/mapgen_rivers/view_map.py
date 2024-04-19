#!/usr/bin/env python3

import numpy as np
import zlib
import sys
import os

from view import stats, plot
from readconfig import read_conf_file

os.chdir(sys.argv[1])
conf = read_conf_file('mapgen_rivers.conf')
if 'center' in conf:
    center = conf['center'] == 'true'
else:
    center = True

if 'blocksize' in conf:
    blocksize = float(conf['blocksize'])
else:
    blocksize = 15.0

def load_map(name, dtype, shape):
    dtype = np.dtype(dtype)
    with open(name, 'rb') as f:
        data = f.read()
        if len(data) < shape[0]*shape[1]*dtype.itemsize:
            data = zlib.decompress(data)
        return np.frombuffer(data, dtype=dtype).reshape(shape)

shape = np.loadtxt('river_data/size', dtype='u4')
shape = (shape[1], shape[0])
dem = load_map('river_data/dem', '>i2', shape)
lakes = load_map('river_data/lakes', '>i2', shape)

stats(dem, lakes, scale=blocksize)
plot(dem, lakes, scale=blocksize, center=center)
