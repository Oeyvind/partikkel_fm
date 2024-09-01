
import sys
import subprocess
# command line args
dataset = sys.argv[1]
#if len(sys.argv) > 2: 
#   saveaudio = False


err1 = subprocess.run(f'python generate_and_analyze.py {dataset} csound')
print('SYNTHESIS done', err1)
#err2 = subprocess.run(f'python generate_and_analyze.py {dataset} spectrogram')
#print('SPECTROGRAM done', err2)
err3 = subprocess.run(f'python display.py {dataset} analyze')