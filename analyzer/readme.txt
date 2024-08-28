To use analyzer:

python generate_and_analyze.py filename
- will render audio with the parameter settings in json files
- graindurs.json and similarly for modindices, delays, grainpitches
- all parameter combinations will be rendered, so it creates a large number of files in /data
- each parameter combination creates a .sco file and a .txt file
- the txt file contains analysis data genereated by Csound
  - it has one line for each sideband subdivision (from 1 to 10)
  - each line has: 
    - number of sidebands found
    - max number of sidebands expoected for this sideband subdivision (in as many octaves as we look into)
    - crest value 
      - the first line has global crest for the sound
      - other lines have average crest over all frequency bands for that sideband division
- an additional argument (any) will also save sound files and spectrum plots for each file
  python generate_and_analyze.py filename True

python display.py
- will show a 3d plot of the analysis data