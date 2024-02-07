
import os, sys
import numpy as np
import numpy.fft as npfft
import matplotlib.pyplot as plt
from scipy.io import wavfile

f1 ='compare_fm_simple_feed.wav' 
f2 = 'compare_partikkel_fm_feed.wav'
if len(sys.argv) > 2:
    f1 = sys.argv[1]
    f2 = sys.argv[2]

fftsize = 8192
sr1,sig1 = wavfile.read(f1)
sr2,sig2 = wavfile.read(f2)

N = 8192
start_seconds = 2 # set position in file, in seconds
start = start_seconds*sr1
x = np.arange(0,N/2)
bins = x*sr1/N
win = np.hanning(N)
scal = N*np.sqrt(np.mean(win**2))

sig1w = sig1[start:N+start]
window1 = npfft.fft(sig1w*win/max(sig1w))
mags1 = abs(window1/scal)
spec1 = 20*np.log10(mags1/max(mags1))

sig2w = sig2[start:N+start]
window2 = npfft.fft(sig2w*win/max(sig2w))
mags2 = abs(window2/scal)
spec2 = 20*np.log10(mags2/max(mags2))

fig, axs = plt.subplots(2, figsize=(10,7))

axs[0].plot(bins,spec1[0:N//2], 'k-')
axs[1].plot(bins,spec2[0:N//2], 'k-')
for a in axs:    
  a.set_ylim(-60,1)
  a.set_ylabel("amp (dB)", size=16)
  a.set_xlabel("freq (Hz)", size=16)
  a.set_yticks([-60,-50,-40,-30,-20,-10,0])
  a.set_xticks([200,600,1000,1400, 1800, 2200, 2600])
  a.set_xlim(0,3000)

axs[0].set_title(f1+': at {} seconds from start of file'.format(start_seconds))
axs[1].set_title(f2+': at {} seconds from start of file'.format(start_seconds))
plt.tight_layout(pad=3.0)
plt.show()
#pylab.savefig('specplot.png')

