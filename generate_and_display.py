
import sys
import subprocess
from collections import OrderedDict

# generate sound with Csound for granular FM
# then plot the results

# set defult p-fields
defaults = OrderedDict()
defaults["dur"] = 4
defaults["amp"] = -6
defaults["cps"] = 400
defaults["cps_end"] = 400
defaults["mod"] = 1
defaults["mod_end"] = 1
defaults["delay"] = 0
defaults["delay_end"] = 0
defaults["lpfq"] = 21000
defaults["lpfq_end"] = 21000
defaults["hpfq"] = 0
defaults["hpfq_end"] = 0
defaults["am"] = 0
defaults["gr.pitch"] = 400
defaults["gr.pitch_end"] = 400
defaults["gr.dur"] = 1.5
defaults["gr.dur_end"] = 1.5
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
    if a2[0]+'_end' in defaults.keys(): # if there is also and 'X_end' parameter name
      defaults[a2[0]+'_end'] = a2[1] # set end value equal to start value (may overwrite by explcit setting later in sys.args)
    else:
      print('No line automation for this parameter {}...skipping the set line end'.format(a2[0]))
    

partikkelwav = sys.argv[1]+'_partikl.wav'
partikkelscore = sys.argv[1]+'score_partikl.sco'
partikkelscorefile = open(partikkelscore, "w")
partikkelscorefile.write('i1 0 ')

for key,value in defaults.items():
  print(key, value)
  partikkelscorefile.write('{} '.format(value))

partikkelscorefile.close()

print('\nNondefault parms:')
print(' '.join(sys.argv[2:]))

err1 = subprocess.run('csound partikkel_fm_feed2.orc {} -o{}'.format(partikkelscore, partikkelwav))
err3 = subprocess.run('python spectrogram_and_waveform.py {} {} {} {} {}'.format(sys.argv[1], partikkelwav, maxfreq, defaults["cps"], ' '.join(sys.argv[2:])))
print('completed: \n', err1, '\n', err3)
