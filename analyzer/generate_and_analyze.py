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
base_filename = sys.argv[1]

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

def render(filename_root, scorestring, mode, saveaudio, filenum, numfiles):
  print(f'... {mode}...working on {filename_root}')
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
  print(f'*** done processing file {filenum} of {numfiles}')

# test parameters
graindurs = np.around(np.arange(0.8,1.61,0.05),2).tolist()
#[0.8, 0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2, 1.3, 1.4, 1.5, 1.6]
modindices = np.around(np.arange(0.8,1.51,0.05),2).tolist()
#[0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5]
delays = [0.17,0.19,0.2,0.23,0.25,0.33,0.4,0.45,0.47,0.49,0.5,0.55,0.6,0.66,0.7,0.75,0.77,0.8,0.9, 1.0, 1.1, 1.25, 1.3, 1.75, 2.25]
#[0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
grainpitches = [200, 400, 580, 600, 670, 800, 1230]
with open("graindurs.json", 'w') as f:
    json.dump(graindurs, f) 
with open("modindices.json", 'w') as f:
    json.dump(modindices, f) 
with open("delays.json", 'w') as f:
    json.dump(delays, f) 
with open("grainpitches.json", 'w') as f:
    json.dump(grainpitches, f) 

filenum = 0
numfiles = len(graindurs) * len(modindices) * len(delays) * len(grainpitches)

for graindur in graindurs:
  defaults["gr.dur"] = graindur
  for modindex in modindices:
    defaults["mod"] = modindex
    for delay in delays:
      defaults["delay"] = delay
      for grainpitch in grainpitches:
        defaults["gr.pitch"] = grainpitch
        path = "./data"
        filename_root = "{}/{}_gd{}_ndx{}_dly{}_gp{}_cps{}".format(path, base_filename, 
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
        print("\n***\nprocessing file {} of {}\n".format(filenum, numfiles))
        pool.submit(render, filename_root, scorestring, mode, saveaudio, filenum, numfiles)
        #if filenum > 10:
        #   sys.exit()
