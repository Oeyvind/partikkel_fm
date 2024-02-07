"""Generate a Spectrogram image for a given WAV audio sample.

A spectrogram, or sonogram, is a visual representation of the spectrum
of frequencies in a sound.  Horizontal axis represents time, Vertical axis
represents frequency, and color represents amplitude.
"""

import os, sys
import numpy
import matplotlib.pyplot as plt
from scipy.io import wavfile

f1 ='compare_fm_simple_feed.wav' 
f2 = 'compare_partikkel_fm_feed.wav'
if len(sys.argv) > 2:
    f1 = sys.argv[1]
    f2 = sys.argv[2]


fftsize = 8192
sr1,sig1 = wavfile.read(f1)
sig1 = sig1[:,0] # left channel of stereo file
sr2,sig2 = wavfile.read(f2)
sig2 = sig2[:,0] # left channel of stereo file
fig, axs = plt.subplots(2, figsize=(10,7))
axs[0].specgram(sig1, Fs=sr1, NFFT=fftsize, vmin=-8)
axs[1].specgram(sig2, Fs=sr2, NFFT=fftsize, vmin=-8)

axs[0].set_ylim(0,3000)
axs[1].set_ylim(0,3000)
axs[0].set_title(f1)
axs[1].set_title(f2)
plt.tight_layout(pad=3.0)
plt.show()
#pylab.savefig('spectrogram.png')


