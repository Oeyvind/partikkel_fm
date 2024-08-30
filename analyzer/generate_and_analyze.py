# generate sound with Csound for granular FM,
# iteratively explore different parameter combinations,
# analyze the timbre complexity (number of sidebands, crest),
# then store the analysis data in a separate file for each parameter combination

import sys, os
import subprocess
from collections import OrderedDict
import json
import numpy as np
import concurrent.futures
pool = concurrent.futures.ThreadPoolExecutor(max_workers=20)

# command line args
dataset = sys.argv[1]

if not sys.argv[2] in ('csound', 'spectrogram'):
   print("second argument must be 'csound' or 'spectrogram'")
   sys.exit()
else:
   mode = sys.argv[2]

saveaudio = True
# if any second argument on the command line, disable save audio files and graphics
# then it will not be possible to do 'spectrogram', and the navigator in the 3d display will not work
if len(sys.argv) > 3: 
   saveaudio = False

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
defaults["gr.pitch"] = 400
defaults["gr.dur"] = 1.5
defaults["adratio"] = 0.5
defaults["sustain"] = 0.33
defaults["index_map"] = 0
defaults["inv_phase2"] = 0
maxfreq = 5000

# read test parameters from file 'dataset_parametervalues.py'
# this should create list objects:
# p.graindurs, p.modindices, p.delays, p.grainpitches
p = ''
get_parameters = f"import {dataset}_parametervalues as p"
exec(get_parameters)

#
def render(filename_root, scorestring, mode, saveaudio, filenum, numfiles):
  if filenum%100 == 0:
    print(f'... file {filenum} {mode}...working on {filename_root}')
  partikkelwav = filename_root+'_partikl.wav'
  if mode == 'csound':
    partikkelscore = filename_root+'_analyze.sco'
    partikkelscorefile = open(partikkelscore, "w")
    partikkelscorefile.write(scorestring) #synthesize
    partikkelscorefile.write('\ni2 0 {} "{}"'.format(defaults["dur"], filename_root)) # analyze
    partikkelscorefile.close()
    if saveaudio:
      err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -o{} -m0 -d'.format(partikkelscore, partikkelwav),stdout=subprocess.DEVNULL,stderr=subprocess.STDOUT)
    else:
      err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -n -m0 -d'.format(partikkelscore))
  if mode == 'spectrogram':
    err2 = subprocess.run('python ../spectrogram_and_waveform.py {} {} {} {} {}'.format(filename_root, partikkelwav, maxfreq, defaults["cps"], "nodisplay"))
  if filenum%100 == 0:
    print(f'*** done {mode} processing file {filenum} of {numfiles}')


filenum = 0
numfiles = len(p.graindurs) * len(p.modindices) * len(p.delays) * len(p.grainpitches)
for graindur in p.graindurs:
  defaults["gr.dur"] = graindur
  for modindex in p.modindices:
    defaults["mod"] = modindex
    for delay in p.delays:
      defaults["delay"] = delay
      for grainpitch in p.grainpitches:
        defaults["gr.pitch"] = grainpitch
        path = "./data"
        filename_root = "{}/{}_gd{}_ndx{}_dly{}_gp{}_cps{}".format(path, dataset, 
                                                           int(defaults["gr.dur"]*1000),
                                                           int(defaults["mod"]*1000), 
                                                           int(defaults["delay"]*1000),
                                                           int(defaults["gr.pitch"]),
                                                           int(defaults["cps"]))

    
        scorestring = 'i1 0 '
        if mode == 'csound':
          for key,value in defaults.items():
            scorestring +='{} '.format(value)
        filenum += 1
        if filenum%100 == 0:
          print("\n***\nprocessing file {} of {}\n".format(filenum, numfiles))
        pool.submit(render, filename_root, scorestring, mode, saveaudio, filenum, numfiles)
        #if filenum > 5:
        #   sys.exit()

