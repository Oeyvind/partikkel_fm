
import sys
import json
import numpy as np
np.set_printoptions(suppress=True, precision=2)
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.widgets import Button, Slider
from  matplotlib.patches import Rectangle
from matplotlib.backend_bases import MouseButton
import subprocess
import os

# read audio analysis files and display analysis data in 3d

# optional argument to load previous analysis from file 
mode = "analyze"
if len(sys.argv) > 1:
    if sys.argv[1] == "saved":
        mode = "saved"

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
if mode == "saved":
    data = np.load("data_array.npy")
else:
    path = "./data/test_"
    data = np.ndarray([len(graindurs), len(modindices), len(delays), len(grainpitches), 3])
    filenum = 0
    numfiles = len(graindurs) * len(modindices) * len(delays) * len(grainpitches)
    for i in range(len(graindurs)):
        g = graindurs[i]
        for j in range(len(modindices)):
            m = modindices[j]
            for k in range(len(delays)):
                d = delays[k]
                for l in range(len(grainpitches)):
                    print("reading file {} of {}".format(filenum, numfiles))
                    p = grainpitches[l]
                    filename = "gd{}_ndx{}_dly{}_gp{}_cps400_analyze.txt".format(int(g*1000),int(m*1000), int(d*1000), int(p))
                    timbre_analysis = get_timbre_analysis(filename, sideband_thresh)
                    data[i][j][k][l] = timbre_analysis
                    filenum += 1

    np.save("data_array.npy", data,) 

# parameter names and their indices into the data array
parms = {"graindur": [graindurs,0], 
         "mod index": [modindices,1], 
         "delay": [delays,2], 
         "grain pitch": [grainpitches,3]}
display_x = "graindur"
display_y = "mod index"
slider_1_parm = "delay"
slider_2_parm = "grain pitch"
init_slider_1 = parms[slider_1_parm][0][3]
init_slider_2 = parms[slider_2_parm][0][1]
displaydata = data[:,:,delays.index(init_slider_1),grainpitches.index(init_slider_2)]

# plot axes
fig, ax0 = plt.subplots()
ax = fig.add_axes([0.2, 0.2, 0.8, 0.8],projection='3d')
axdelay = fig.add_axes([0.2, 0.1, 0.6, 0.03])
axdelay2 = fig.add_axes([0.2, 0.15, 0.6, 0.03])
axpitch = fig.add_axes([0.2, 0.05, 0.6, 0.03])
ax_legend = fig.add_axes([0.03, 0.7, 0.2, 0.2])
ax_navigator = fig.add_axes([0.03, 0.25, 0.25, 0.35])
ax_navigator.set_xticks([])
ax_navigator.set_yticks([])

# 3d grid for barplot
x_parm = parms[display_x][0]
y_parm = parms[display_y][0]
x,y = np.meshgrid(x_parm, y_parm)
xx,yy = x.ravel(), y.ravel()

# Make horizontal sliders to control the extra parameters
slider_1 = Slider(
    ax=axdelay,
    label= slider_1_parm,
    valmin = min(parms[slider_1_parm][0]),
    valmax = max(parms[slider_1_parm][0]),
    valinit = init_slider_1,
    valstep = parms[slider_1_parm][0],
    color='lightgrey'
)
# make slider grayed out, as we should use it only for display
rect_gray = Rectangle((0, 0), 3, 3, color=(0.5,0.5,0.5,0.7))
axdelay.add_artist(rect_gray)

slider_1c = Slider(
    ax=axdelay2,
    label= "delay_control",
    valmin = 0,
    valmax = len(parms[slider_1_parm][0])-1,
    valinit = 3,
    valstep = 1
)
def set_delay(val):
    slider_1.set_val(parms[slider_1_parm][0][val])

slider_2 = Slider(
    ax=axpitch,
    label= slider_2_parm,
    valmin = min(parms[slider_2_parm][0]),
    valmax = max(parms[slider_2_parm][0]),
    valinit = init_slider_2,
    valstep = parms[slider_2_parm][0]#[1]-parms[slider_2_parm][0][0]
)

# color legend
rect_red = Rectangle((0, 0.9), 0.1, 0.1, color='red')
ax_legend.add_artist(rect_red)
ax_legend.text(0.15, 0.9, "Global crest", dict(size=8))
rect_blue = Rectangle((0, 0.7), 0.1, 0.1, color='blue')
ax_legend.add_artist(rect_blue)
ax_legend.text(0.15, 0.7, "Sideband crest", dict(size=8))
rect_black = Rectangle((0, 0.5), 0.1, 0.1, color=(0.2,0.2,0.2))
ax_legend.add_artist(rect_black)
ax_legend.text(0.15, 0.5, "Probably noisy", dict(size=8))
ax_legend.axis('off')

# The function to redraw the plot
def update(val):
    ax.clear()
    displaydata = data[:,:,delays.index(slider_1.val),grainpitches.index(slider_2.val)]
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
    ax.set_xticks(list(x_parm[i] for i in range(0,len(x_parm),4)))
    ax.set_yticks(list(y_parm[i] for i in range(0,len(y_parm),4)))
    ax.set_xlabel(display_x) 
    ax.set_ylabel(display_y)
    ax.set_zlabel("sidebands")
    ax.set_title('Sidebands analysis')
    # navigator
    global navigator_colors_t
    navigator_colors = np.ndarray((len(x_parm),len(y_parm),4))
    for i in range(len(colors)):
        navigator_colors[i%len(x_parm),int(i/len(x_parm))] = colors[i]
    navigator_colors_t = navigator_colors
    navigator_colors = np.rot90(navigator_colors)
    ax_navigator.imshow(navigator_colors) 
    fig.canvas.draw_idle()

# register the update function with each slider
slider_2.on_changed(update)
slider_1.on_changed(update)
slider_1c.on_changed(set_delay)


update(1)
def on_move(event):
    if (event.inaxes == ax_navigator):
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1
        #print(f'data coords {x} {y}  {parms[display_x][0][x]} {parms[display_y][0][y]}  {navigator_colors_t[x,y]}')

def on_click(event):
    if (event.inaxes == ax_navigator):
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1
        #print(f'file test_gd{int(parms[display_x][0][x]*1000)}_ndx{int(parms[display_y][0][y]*1000)}_dly{int(slider_1.val*1000)}_gp{int(slider_2.val)}_cps400_display.png')
        png_file = f'./data/test_gd{int(parms[display_x][0][x]*1000)}_ndx{int(parms[display_y][0][y]*1000)}_dly{int(slider_1.val*1000)}_gp{int(slider_2.val)}_cps400_display.png'
        wav_file = f'./data/test_gd{int(parms[display_x][0][x]*1000)}_ndx{int(parms[display_y][0][y]*1000)}_dly{int(slider_1.val*1000)}_gp{int(slider_2.val)}_cps400_partikl.wav'
        print(png_file)
        #os.startfile(filename, 'open')
        platform = sys.platform
        print(platform)
        if platform == 'darwin':
            subprocess.call(('open', png_file))
            subprocess.call(('open', wav_file))
        elif platform in ['win64', 'win32']:
            subprocess.call(('cmd', '/C', 'start', '', png_file))
            subprocess.call(('cmd', '/C', 'start', '', wav_file))

binding_id = plt.connect('motion_notify_event', on_move)
plt.connect('button_press_event', on_click)

ax0.axis('off')
plt.show()
