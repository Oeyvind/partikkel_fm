
import sys
import subprocess

# generate sound with Csound for simple FM and granular FM
# then plot the results

if len(sys.argv) > 2:
    csd1 = sys.argv[1]
    csd2 = sys.argv[2]
else:
    print('Please provide two source csd files')
sf1 = csd1[:-4]+'.wav'
sf2 = csd2[:-4]+'.wav'

err1 = subprocess.run('csound {} -o{}'.format(csd1, sf1))
err2 = subprocess.run('csound {} -o{}'.format(csd2, sf2))
err3 = subprocess.run('python compare_spectrogram.py {} {}'.format(sf1,sf2))
print('completed: \n', err1, '\n', err2, '\n', err3)

