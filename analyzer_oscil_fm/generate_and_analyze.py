# generate sound with Csound for oscillator FM,
# iteratively explore different parameter combinations,
# analyze the timbre complexity (pitch stability, crest, ...),
# then store the analysis data in a separate file for each parameter combination

import sys, os
import subprocess
from collections import OrderedDict
import json
import numpy as np
import concurrent.futures
pool = concurrent.futures.ThreadPoolExecutor(max_workers=25)

# command line args
dataset = sys.argv[1]
if not sys.argv[2] in ('csound', 'spectrogram'):
   print("second argument must be 'csound' or 'spectrogram'")
   sys.exit()
else:
   mode = sys.argv[2]

# set defult p-fields
defaults = OrderedDict()
defaults["dur"] = 2
defaults["amp"] = -6
defaults["cps"] = 400
defaults["mod"] = 1
defaults["delay"] = 0
defaults["lpfq"] = 21000
defaults["hpfq"] = 0
defaults["am"] = 0
maxfreq = 5000

# read test parameters from file 'dataset_parametervalues.py'
# this should create list objects:
# p.modindices, p.delays, p.am
p = ''
get_parameters = f"import {dataset}_parametervalues as p"
exec(get_parameters)

#
def render(filename_root, scorestring, mode, filenum, numfiles):
  if filenum%100 == 0:
    print(f'... file {filenum} {mode}...working on {filename_root}')
  fmwav = filename_root+'_fm.wav'
  if mode == 'csound':
    fmscore = filename_root+'_analyze.sco'
    fmscorefile = open(fmscore, "w")
    fmscorefile.write(scorestring) #synthesize and analyze
    fmscorefile.close()
    err1 = subprocess.run('csound fm_osc_feed_analyze.orc {} -n -m0 -d'.format(fmscore),stdout=subprocess.DEVNULL,stderr=subprocess.STDOUT)
  if mode == 'spectrogram':
    err2 = subprocess.run('python ../spectrogram_and_waveform.py {} {} {} {} {}'.format(filename_root, fmwav, maxfreq, defaults["cps"], "nodisplay"))
  if filenum%100 == 0:
    print(f'*** done {mode} processing file {filenum} of {numfiles}')


filenum = 0
numfiles = len(p.modindices) * len(p.delays) * len(p.am)
for modindex in p.modindices:
  defaults["mod"] = modindex
  for delay in p.delays:
    defaults["delay"] = delay
    for am in p.am:
      defaults["am"] = am
      path = "./data"
      filename_root = "{}/{}_ndx{}_dly{}_am{}_cps400".format(path, dataset, 
                                                      int(defaults["mod"]*1000), 
                                                      int(defaults["delay"]*1000),
                                                      int(defaults["am"]))
  
      scorestring = 'i1 0 ' # synthesize
      if mode == 'csound':
        for key,value in defaults.items():
          scorestring +='{} '.format(value)
      scorestring += '\ni2 0 {} {} "{}"'.format(defaults["dur"], defaults["cps"], filename_root) # analyze
      filenum += 1
      #if filenum%100 == 0:
      print("\n***\nprocessing file {} of {}\n".format(filenum, numfiles))
      pool.submit(render, filename_root, scorestring, mode, filenum, numfiles)
      #render(filename_root, scorestring, mode, filenum, numfiles)
      #if filenum > 5:
      #   sys.exit()
