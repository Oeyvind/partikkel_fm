# generate sound with Csound for granular FM,
# debug the audio analysis 
# display spectrogram

import sys, os
import subprocess
from collections import OrderedDict
import numpy as np

# command line args
filename = sys.argv[1]

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

# command line override
for a in sys.argv[2:]:
  a2 = a.split('=')
  if a2[0] == 'maxfreq':
    maxfreq = a2[1]
  else:
    defaults[a2[0]] = a2[1] # set parameter value


partikkelwav = sys.argv[1]+'_partikl.wav'
partikkelscore = sys.argv[1]+'score_partikl.sco'
partikkelscorefile = open(partikkelscore, "w")
partikkelscorefile.write('i1 0 ')

for key,value in defaults.items():
  print(key, value)
  partikkelscorefile.write('{} '.format(value))
partikkelscorefile.write('\ni2 0 {} {} "{}"'.format(defaults["dur"], defaults["cps"], filename)) # analyze

partikkelscorefile.close()

print('\nNondefault parms:')
print(' '.join(sys.argv[2:]))

err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -o{}'.format(partikkelscore, partikkelwav))
err3 = subprocess.run('python ../spectrogram_and_waveform.py {} {} {} {} {}'.format(sys.argv[1], partikkelwav, maxfreq, defaults["cps"], ' '.join(sys.argv[2:])))
print('completed: \n', err1, '\n', err3)

