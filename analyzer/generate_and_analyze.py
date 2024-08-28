
import sys
import subprocess
from collections import OrderedDict
import json

# generate sound with Csound for granular FM,
# iteratively explore different parameter combinations,
# analyze the timbre complexity (number of sidebands, crest),
# then store the analysis data in a separate file for each parameter combination
save_audio_display = False
if len(sys.argv) > 2: # if any second argument on the command line, save audio files and graphics
   save_audio_display = True

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

def render(filename_root, save_audio_display=False):
  partikkelwav = filename_root+'_partikl.wav'
  partikkelscore = filename_root+'_analyze.sco'
  partikkelscorefile = open(partikkelscore, "w")
  partikkelscorefile.write('i1 0 ') # synthesize

  for key,value in defaults.items():
    partikkelscorefile.write('{} '.format(value))
    if key in ["cps", "mod", "delay", "gr.pitch", "gr.dur"]:
      print(key, value)

  partikkelscorefile.write('\ni2 0 {} "{}"'.format(defaults["dur"], filename_root)) # analyze
  partikkelscorefile.close()
  #print('\nNondefault parms:')
  #print(' '.join(sys.argv[2:]))
  if save_audio_display:
    err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -o{} -m0 -d'.format(partikkelscore, partikkelwav))
    err2 = subprocess.run('python ../spectrogram_and_waveform.py {} {} {} {} {}'.format(filename_root, partikkelwav, maxfreq, defaults["cps"], "nodisplay"))
    print('completed: \n', err1, err2)
  else:
    err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -n -m0 -d'.format(partikkelscore))
    print('completed: \n', err1)

# test parameters
graindurs = [0.7, 1.0, 1.3, 1.6]
modindices = [0.8, 1, 1.2, 1.4]
delays = [0.25, 0.5, 0.75, 1]
grainpitches = [200,300,400,500]
with open("graindurs.json", 'w') as f:
    json.dump(graindurs, f) 
with open("modindices.json", 'w') as f:
    json.dump(modindices, f) 
with open("delays.json", 'w') as f:
    json.dump(delays, f) 
with open("grainpitches.json", 'w') as f:
    json.dump(grainpitches, f) 

for graindur in graindurs:
  defaults["gr.dur"] = graindur
  for modindex in modindices:
    defaults["mod"] = modindex
    for delay in delays:
      defaults["delay"] = delay
      for grainpitch in grainpitches:
        defaults["gr.pitch"] = grainpitch
        path = "./data"
        filename_root = "{}/{}_gd{}_ndx{}_dly{}_gp{}_cps{}".format(path, sys.argv[1], 
                                                           int(defaults["gr.dur"]*1000),
                                                           int(defaults["mod"]*1000), 
                                                           int(defaults["delay"]*1000),
                                                           int(defaults["gr.pitch"]),
                                                           int(defaults["cps"]))
        render(filename_root, save_audio_display)
