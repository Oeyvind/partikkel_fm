"""Generate a Spectrogram image for a given WAV audio sample.

A spectrogram, or sonogram, is a visual representation of the spectrum
of frequencies in a sound.  Horizontal axis represents time, Vertical axis
represents frequency, and color represents amplitude.
"""

import os, sys
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

basefilename = sys.argv[1]
f1 = sys.argv[2]
maxfreq = int(sys.argv[3])
basefreq = float(sys.argv[4])
nondefaults = ' '.join(sys.argv[5:])

fftsize = 8192
sr1,sig1 = wavfile.read(f1)
sig1n = np.array(sig1,dtype=float)
sig1n /= np.max(sig1)
samples_per_cycle = int(sr1/basefreq)*4
soundlen_sec = len(sig1)/sr1
numslices = 8
fig, axs = plt.subplots(3, figsize=(10,7), height_ratios=[4, 1, 0.1])

axs[0].specgram(sig1, Fs=sr1, NFFT=fftsize, vmin=0)
waveslices1 = []
slice_starts = []
for i in range(numslices):
  slice_start = int(sr1*i/(numslices/soundlen_sec))
  slice_starts.append(i*samples_per_cycle)
  waveslices1.extend(sig1n[slice_start:slice_start+samples_per_cycle])
axs[1].plot(waveslices1, linewidth=0.7)
axs[1].vlines(slice_starts, -1, 1, color='red')

axs[0].set_ylim(0,maxfreq)
axs[0].set_xlim(0,soundlen_sec)
axs[1].set_xlim(0,len(waveslices1))

axs[1].axis('off')
axs[2].axis('off')

axs[2].annotate('nondefault parms: '+nondefaults, (0,0))
axs[0].set_title(f1)
plt.tight_layout()
plt.savefig(basefilename+'_display.png')
plt.show()



