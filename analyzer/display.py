
import sys
import json
import numpy as np
np.set_printoptions(suppress=True, precision=2)
import matplotlib.pyplot as plt
from matplotlib import cm

# read audio analysis files and display

# get parameter values
with open("graindurs.json", 'r') as f:
    graindurs = json.load(f) 
with open("modindices.json", 'r') as f:
    modindices = json.load(f) 
with open("delays.json", 'r') as f:
    delays = json.load(f) 
with open("grainpitches.json", 'r') as f:
    grainpitches = json.load(f) 

sideband_thresh = 0.7 # ratio of sidebands present (with relation to max number of bands that could be present) for each N-subdiv sidebands

def get_timbre_analysis(f, sideband_thresh):
    #print(filename)
    f = open(path+filename, "r")
    timbre_data = []
    for line in f.readlines():
        timbre_data.append(line.rstrip('\n').split('\t'))
    crest_global = timbre_data[0][2]
    sideband_div = 1
    for i in range(1,len(timbre_data)):
        if float(timbre_data[i][0]) > float(timbre_data[i][1])*sideband_thresh:
            sideband_div = i
    crest_sideband = timbre_data[sideband_div][2]
    #print(sideband_div, crest_sideband, crest_global)            
    return sideband_div, crest_sideband, crest_global

# get data
# 1. read file, determine which sideband we want
# 2. make 2D data structure with graindur and modindex as the dimensions
#   - the data structure does not have labels, it is just 2D arrays
#   - the parameter lists can be used to correctly label the data (e.g. graindur=0.7, modindex=0.8 is at index 0,0)
path = "./data/test_"
data = np.ndarray([len(graindurs), len(modindices), len(delays), len(grainpitches), 3])
for i in range(len(graindurs)):
    g = graindurs[i]
    for j in range(len(modindices)):
        m = modindices[j]
        for k in range(len(delays)):
            d = delays[k]
            for l in range(len(grainpitches)):
                p = grainpitches[l]
                filename = "gd{}_ndx{}_dly{}_gp{}_cps400_analyze.txt".format(int(g*1000),int(m*1000), int(d*1000), int(p))
                timbre_analysis = get_timbre_analysis(filename, sideband_thresh)
                data[i][j][k][l] = timbre_analysis
       
print(data)
for g in graindurs:
    for m in modindices:
        for d in delays:
            for p in grainpitches:
                print("graindur", g, "modindex", m, "delay", d, "grainpitch", p, "\n", 
                      data[graindurs.index(g)]
                      [modindices.index(m)]
                      [delays.index(d)]
                      [grainpitches.index(p)])


# data filtering
# to show graindur vs modindex at delay=0.5 and pitch=200
#displaydata = data[:,:,delays.index(0.25),grainpitches.index(200)]
# to show delay vs graipitch
#displaydata = data[graindurs.index(0.7),modindices.index(0.8),:,:]
#print(displaydata)

# parameter names and their indices into the data array
parms = {"graindur": [graindurs,0], "mod index": [modindices,1], "delay": [delays,2], "grain pitch": [grainpitches,3]}
display_x = "graindur"
display_y = "mod index"
# TODO: datafiltering
# to show graindur vs modindex at delay=0.5 and pitch=200
#displaydata = data[:,:,delays.index(0.75),grainpitches.index(400)]
displaydata = data[:,:,delays.index(0.75),grainpitches.index(400)]

'''
test1 = displaydata[graindurs.index(0.7),modindices.index(0.8)]
test2 = displaydata[graindurs.index(1.0),modindices.index(0.8)]
test3 = displaydata[graindurs.index(1.3),modindices.index(0.8)]
test4 = displaydata[graindurs.index(1.6),modindices.index(0.8)]
print("\n graindur 0.7 to 1.6, modindex 0.8")
print(test1)
print(test2)
print(test3)
print(test4)
'''

# plot
fig = plt.figure()
ax = plt.axes(projection='3d')
x_parm = parms[display_x][0]
y_parm = parms[display_y][0]
x,y = np.meshgrid(x_parm, y_parm)
xx,yy = x.ravel(), y.ravel()

# get analysis, must transpose (swap axes)
sideband_div = np.transpose(displaydata[:,:,0]).ravel() 
crests = np.transpose(displaydata[:,:,2]).ravel()
sideband_crests = np.transpose(displaydata[:,:,1]).ravel()

width = (x_parm[1]-x_parm[0])*0.9
depth = (y_parm[1]-y_parm[0])*0.9
colors = np.zeros((len(crests),4))
red = ((crests/max(crests))*0.9)+0.1
blue = ((sideband_crests/max(sideband_crests))*0.8)+0.2
green = 0.5#0.3-(red+blue)*0.1
colors[:,0] = red
colors[:,1] = 0.2#green #0.2 # 
colors[:,2] = blue
colors[:,3] = 1 # opacity

ax.bar3d(xx, yy, 0, width, depth, sideband_div, color=colors)
ax.set_xlabel(display_x) 
ax.set_xticks(x_parm)
ax.set_ylabel(display_y)
ax.set_yticks(y_parm)
ax.set_zlabel("sidebands")
ax.set_title('Sidebands analysis')
plt.show()
