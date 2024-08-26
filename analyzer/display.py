
import sys
import json
import numpy as np
import matplotlib.pyplot as plt

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

# get data
fileroot = "./data/test_"
# ***todo*** for g in graindurs, m in modindices ...
# must be able to look up data by keywords: graindur, modindex
# we also should filer the data here, so we only read the highest number of sidebands and the global crest
# ... so it is two operations:
# 1. read file, determine which sideband we want
# 2. make 2D data structure with graindur and modindex as the dimensions
#   - the data structure does not have labels, it is just 2D arrays
#   - the parameter lists can be used to correctly label the data (e.g. graindur=0.7, modindex=0.8 is at index 0,0)

f = open(fileroot+"gd700_ndx_800_dly750_gp400_cps400_analyze.txt", "r")
l1 = []
for line in f.readlines():
    l1.append(line.rstrip('\n').split('\t'))
f = open(fileroot+"gd1000_ndx_800_dly750_gp400_cps400_analyze.txt", "r")
l2 = []
for line in f.readlines():
    l2.append(line.rstrip('\n').split('\t'))
d0 = dict()
d0['gd700'] = l1
d0['gd1000'] = l2
print(d0)
          

'''
# plot
# defining surface and axes
x = np.outer(np.linspace(-2, 2, 10), np.ones(10))
y = x.copy().T
z = np.cos(x ** 2 + y ** 3)
 
fig = plt.figure()
 
# syntax for 3-D plotting
ax = plt.axes(projection='3d')
 
# syntax for plotting
ax.plot_surface(x, y, z, cmap='viridis',\
                edgecolor='green')
ax.set_title('Surface plot geeks for geeks')
plt.show()
'''