The experiments branch allows new development without interfering with the main branch (used for the 2024 Csound conference paper.)
Experiments are 
  - a systematic exploration of parameter combinations that might lead to interesting results
  - one quality criteria for "interesting" is timbres that show relatively high complexity while being pitch stable
  - another criteria for interesting is controlled transitions between simple and complex timbres

Experiment notes can be found in .txt files such as 
ndx_dly_0_notes.txt
ndx_dur_0_notes.txt
ndx_pitch_0_notes.txt
ptch_dly_0_notes.txt
ptch_dur_0_notes.txt
ptch_mod_0_notes.txt
dur_...(yet to be done)
dly_...(yet to be done)
...
The experiment notes filename alludes to the parameters being experimented on. The first name (e.g. ndx = modulation index) is automated with a line, the second name (e.g. dly) has a set value for each experiment file.



--- regular redme below this point ---

Examples of fm feedback in granular synthesis, comparing it to simple fm feedback with regular oscillators

To run synthesis of the two types of fm feedback run:
python generate_and_compare.py soundfilename
The first argument sets the initial file name of the generated sound file (appended differently for the two different synthesis models)
The script will display a spectrogram of both generated sound files, and also a zoomed in audio waveform snippet at regular time intervals (0.5 seconds by default).

Synthesis parameters can be set from the python command, for example like:
python generate_and_compare.py soundfile hpfq=1
... which will enable the hipass filter in the fm feedback signal and use a filter cutoff of 1Hz

The default values are:
["dur"] = 4 # duration of the generated sound
["amp"] = -6 # amplitude of the generated sound
["cps"] = 400 # fundamental frequency (= grain rate for the granular model)
["mod1"] = 0 # fm index at start of sound
["mod2"] = 1.5 # fm index at end of sound
["delay"] = 0 # delay in the fm feedback, in fractions of a full wave cycle (fundamental freq for simple fm, grain pitch for granular) 
["lpfq"] = 21000 # cutoff (in Hz) of the lowpass filter in the fm feedback, values above 20000 bypass the filter
["hpfq"] = 0 # cutoff (in Hz) of the highpass filter in the fm feedback, values below 0.1 bypass the filter
["am"] = 0 # enable or disable amplitude modulation in the fm feedback. May help stabilize pitch.
["gr.pitch"] = 400 # frequency of the waveform indise each grain (for granular only)
["gr.dur"] = 1.5 # grain duration ((for granular only))
["adratio"] = 0.5 # attack to decay ratio for envelope on each grain (for granular only)
["sustain"] = 0.33 # sustain of envelope for each grain (for granular only)
["index_map"] = 0 # enable fm modulation index adjustment for the granular model (experimental)
["inv_phase2"] = 0 # if enabled, we invert the phase of every second grain and double the grain rate, as a variant of bipolar AM
["maxfreq] = 5000 # the maximum frequency to display in the spectrum plot

The index_map setting attempts to take into account that the grain duration naturally will affect the amount of modulation that can occur in granular fm feedback. 

To Victor, things to test:

python generate_and_compare.py 1 delay=0.75 gr.pitch=800 cps=800 index_map=1
- here we see more clearly how the different sidebands enter. We seem to get sidebands at cps/2, then cps/4 ?

python generate_and_compare.py 1 delay=0.25 mod2=3
- here we see a good example of sidebands getting chaotic in granular, then coming back into order (an octave above)

python generate_and_compare.py 1 delay=1.5
- here we see the sub-cps sidebands more cleary in simple fm feedback

