
import sys
import subprocess
from collections import OrderedDict

# generate sound with Csound for simple FM and granular FM
# then plot the results

# set defult p-fields
defaults = OrderedDict()
defaults["dur"] = 4
defaults["amp"] = -6
defaults["cps"] = 400
defaults["mod1"] = 0
defaults["mod2"] = 1.5
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
    defaults[a2[0]] = a2[1]


partikkelscore = open("score_partikkel.sco", "w")
partikkelscore.write('i1 0 ')
fmscore = open("score_fm.sco", "w")
fmscore.write('i1 0 ')

p = 2 # keep track of p-fields as the two scores differ
for key,value in defaults.items():
  print(key, value)
  p += 1
  if p <= 11: 
    partikkelscore.write('{} '.format(value))
    fmscore.write('{} '.format(value))
  else:
    partikkelscore.write('{} '.format(value))

partikkelscore.close()
fmscore.close()


print(' '.join(sys.argv[2:]))

fmfile = sys.argv[1]+'_fm.wav'
partikkelfile = sys.argv[1]+'_partikl.wav'

err1 = subprocess.run('csound partikkel_fm_feed.orc score_partikkel.sco -o{}'.format(partikkelfile))
err2 = subprocess.run('csound fm_simple_feed.orc score_fm.sco -o{}'.format(fmfile))
err3 = subprocess.run('python compare_spectrogram_and_waveform.py {} {} {} {} {}'.format(partikkelfile, fmfile, maxfreq, defaults["cps"], ' '.join(sys.argv[2:])))
print('completed: \n', err1, '\n', err2, '\n', err3)
