
import sys
import json
import numpy as np
np.set_printoptions(suppress=True, precision=2)
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.widgets import CheckButtons, Slider
from  matplotlib.patches import Rectangle
from matplotlib.backend_bases import MouseButton
import subprocess
import os
from threading import Thread
import time
import ctcsound
 
# read audio analysis files and display analysis data in 3d

# select dataset, e.g. 'test_'
dataset = sys.argv[1]

# optional argument to load previous analysis from file 
mode = "analyze"
if len(sys.argv) > 2:
    if sys.argv[2] == "saved":
        mode = "saved"

# read test parameters from file 'dataset_parametervalues.py'
# this should create list objects:
# p.graindurs, p.modindices, p.delays, p.grainpitches
p = ''
get_parameters = f"import {dataset}_parametervalues as p"
exec(get_parameters)


sideband_thresh = 0.7 # ratio of sidebands present (with relation to max number of bands that could be present) for each N-subdiv sidebands

def get_timbre_analysis(filename, sideband_thresh):
    f = open(path+filename, "r")
    timbre_data = []
    for line in f.readlines():
        timbre_data.append(line.rstrip('\n').split('\t'))
    #print(filename)
    #print(timbre_data)
    dc_amp = float(timbre_data[0][0])
    crest_global = float(timbre_data[0][1])
    centroid = float(timbre_data[0][2])
    rolloff = float(timbre_data[0][3])
    sideband_div = 1
    for i in range(1,len(timbre_data)):
        if float(timbre_data[i][0]) > float(timbre_data[i][1])*sideband_thresh:
            sideband_div = i
    crest_sideband = float(timbre_data[sideband_div][2])
    if crest_sideband < 1:
        sideband_div = -1
    return sideband_div, crest_sideband, dc_amp, crest_global, centroid, rolloff

# get data
if mode == "saved":
    data = np.load(f"{dataset}_data_array.npy")
else:
    path = f"./data/"
    data = np.ndarray([len(p.graindurs), len(p.modindices), len(p.delays), len(p.grainpitches), 6])
    filenum = 0
    numfiles = len(p.graindurs) * len(p.modindices) * len(p.delays) * len(p.grainpitches)
    for i in range(len(p.graindurs)):
        g = p.graindurs[i]
        for j in range(len(p.modindices)):
            m = p.modindices[j]
            for k in range(len(p.delays)):
                d = p.delays[k]
                for l in range(len(p.grainpitches)):
                    if filenum%100 == 0:                    
                        print("reading file {} of {}".format(filenum, numfiles))
                    gp = p.grainpitches[l]
                    filename = "{}_gd{}_ndx{}_dly{}_gp{}_cps400_analyze.txt".format(dataset, int(g*1000),int(m*1000), int(d*1000), int(gp))
                    timbre_analysis = get_timbre_analysis(filename, sideband_thresh)
                    data[i][j][k][l] = timbre_analysis
                    filenum += 1

    np.save(f"{dataset}_data_array.npy", data,) 

# parameter names and their indices into the data array
parms = {"graindur": [p.graindurs,0], 
         "mod index": [p.modindices,1], 
         "delay": [p.delays,2], 
         "grain pitch": [p.grainpitches,3]}

# it works best if the parameters displayed on X and Y axis are linearly spaced
displaypreset = 1
if displaypreset == 1:
    display_x = "graindur"
    display_y = "mod index"
    slider1_parm = "delay"
    slider2_parm = "grain pitch"
    displaydata = data[:,:,0,0]
elif displaypreset == 2:
    display_x = "delay" 
    display_y = "grain pitch"
    slider1_parm = "graindur" 
    slider2_parm = "mod index"
    displaydata = data[0,0,:,:]
elif displaypreset == 3:
    display_x = "delay" 
    display_y = "mod index"
    slider1_parm = "graindur" 
    slider2_parm = "grain pitch"
    displaydata = data[0,:,:,0]

slider1_data = parms[slider1_parm][0]
slider2_data = parms[slider2_parm][0]

# run realtime Csound to synthesize the sound with parameters set by moving the mouse in the 2d plot
cs = ctcsound.Csound()
orc = open("partikkel_fm_feed_analyze.orc", "r")
result = cs.setOption("-odac")
result = cs.setOption("-d")
cs.compileOrc(orc.read())
cs.readScore('')
cs.start()            
csthread = ctcsound.CsoundPerformanceThread(cs.csound()) 
csthread.play() 
'''
cs.setControlChannel("amp", 0)
cs.setControlChannel("grainrate", 400)
cs.setControlChannel("modindex", 0.5)
cs.setControlChannel("delaytime", 0.5)
cs.setControlChannel("grainpitch", 400)
cs.setControlChannel("graindur", 0.5)
'''
# plot axes
fig, ax0 = plt.subplots()
ax = fig.add_axes([0.2, 0.2, 0.8, 0.8],projection='3d')
ax_slider1 = fig.add_axes([0.2, 0.1, 0.6, 0.03])
ax_slider1_val = fig.add_axes([0.81, 0.1, 0.1, 0.03])
ax_slider2 = fig.add_axes([0.2, 0.05, 0.6, 0.03])
ax_slider2_val = fig.add_axes([0.81, 0.05, 0.1, 0.03])
#ax_checkbox = fig.add_axes([0.91, 0.05, 0.1, 0.1])
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
slider1 = Slider(
    ax= ax_slider1,
    label = slider1_parm,
    valmin = 0,
    valmax = len(parms[slider1_parm][0])-1,
    valinit = 0,
    valstep = 1
)
slider1.valtext.set_visible(False)

slider2 = Slider(
    ax = ax_slider2,
    label= slider2_parm,
    valmin = 0,
    valmax = len(parms[slider2_parm][0])-1,
    valinit = 0,
    valstep = 1
)
slider2.valtext.set_visible(False)
'''
check = CheckButtons(
    ax=ax_checkbox,
    labels=['run_d','run_p'],
    actives=[False, False],
    label_props={'color': ['black','red']},
)
'''

# color legend
rect_blue = Rectangle((0, 0.9), 0.1, 0.1, color='blue')
ax_legend.add_artist(rect_blue)
ax_legend.text(0.15, 0.9, "Sideband crest", dict(size=8))
rect_green = Rectangle((0, 0.7), 0.1, 0.1, color='green')
ax_legend.add_artist(rect_green)
ax_legend.text(0.15, 0.7, "Rolloff", dict(size=8))
rect_red = Rectangle((0, 0.5), 0.1, 0.1, color='red')
ax_legend.add_artist(rect_red)
ax_legend.text(0.15, 0.5, "DC component", dict(size=8))
#rect_black = Rectangle((0, 0.5), 0.1, 0.1, color=(0.2,0.2,0.2))
#ax_legend.add_artist(rect_black)
#ax_legend.text(0.15, 0.5, "Probably noisy", dict(size=8))
ax_legend.axis('off')

# The function to redraw the plot
def update(val):
    ax.clear()
    if displaypreset == 1:
        displaydata = data[:,:,slider1.val,slider2.val]
        print(slider1.val, slider2.val)
        cs.setControlChannel("delay", parms[slider1_parm][0][slider1.val])
        cs.setControlChannel("grainpitch", parms[slider2_parm][0][slider2.val])
    elif displaypreset == 2:
        displaydata = data[slider1.val,slider2.val,:,:]
    elif displaypreset == 3:
        displaydata = data[slider1.val,:,:,slider2.val]
    # get analysis, must transpose (swap axes)
    sideband_div = np.transpose(displaydata[:,:,0]).ravel() 
    sideband_crests = np.transpose(displaydata[:,:,1]).ravel()
    dc_amp = np.transpose(displaydata[:,:,2]).ravel()
    crest = np.transpose(displaydata[:,:,3]).ravel()
    centroid = np.transpose(displaydata[:,:,4]).ravel()
    rolloff = np.transpose(displaydata[:,:,5]).ravel()
    #rolloff /= np.power(sideband_div,0.2) #scale according to number of sidebands
    width = (x_parm[1]-x_parm[0])*0.9
    depth = (y_parm[1]-y_parm[0])*0.9
    colors = np.zeros((len(crest),4))
    red = np.power(dc_amp, 0.5) # we use DC relative to sum amp, so it is already normalized
    blue = (np.power((sideband_crests/max(sideband_crests)),1)*0.9)+0.1
    green = np.power(rolloff, 0.3) # rollof is relative to sum amp, so it is already normalized
    colors[:,0] = red
    colors[:,1] = green #0.2 # 
    colors[:,2] = blue
    colors[:,3] = 1 # opacity
    ax.bar3d(xx, yy, 0, width, depth, sideband_div, color=colors, shade=True)
    ax.set_xticks(list(x_parm[i] for i in range(0,len(x_parm),4)))
    ax.set_yticks(list(y_parm[i] for i in range(0,len(y_parm),4)))
    ax.set_xlabel(display_x) 
    ax.set_ylabel(display_y)
    ax.set_zlabel("sidebands")
    ax.set_zlim(0,10)
    ax.set_title('Sidebands analysis')
    # sliders
    ax_slider1_val.clear()
    ax_slider1_val.axis('off')
    ax_slider1_val.text(0.1, 0.1, str(parms[slider1_parm][0][slider1.val]))
    ax_slider2_val.clear()
    ax_slider2_val.axis('off')
    ax_slider2_val.text(0.1, 0.1, str(parms[slider2_parm][0][slider2.val]))
    # navigator
    navigator_colors = np.ndarray((len(x_parm),len(y_parm),4))
    for i in range(len(colors)):
        navigator_colors[i%len(x_parm),int(i/len(x_parm))] = colors[i]
    navigator_colors = np.rot90(navigator_colors)
    ax_navigator.imshow(navigator_colors) 
    fig.canvas.draw_idle()

# register the update function with each slider
slider2.on_changed(update)
slider1.on_changed(update)

update(1)

def on_enter(event):
  if (event.inaxes == ax_navigator):
    print('enter')
    cs.setControlChannel("amp", 1)

def on_leave(event):
  if (event.inaxes == ax_navigator):
    print('leave')
    cs.setControlChannel("amp", 0)

# set defult p-fields for csound realtime score events
from collections import OrderedDict
defaults = OrderedDict()
defaults["dur"] = 2
defaults["amp"] = -6
defaults["cps"] = 400
defaults["mod"] = 1
defaults["delay"] = 0
defaults["lpfq"] = 21000
defaults["hpfq"] = 0
defaults["am"] = 0
defaults["gr.pitch"] = 400
defaults["gr.dur"] = 1.5
defaults["adratio"] = 0.5
defaults["sustain"] = 0.33
defaults["index_map"] = 0
defaults["inv_phase2"] = 0

old_xy = [0,0]
def on_move(event):
    if (event.inaxes == ax_navigator):
        global old_xy
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1
        if [x,y] != old_xy:
          print('graindur', parms[display_x][0][x], 'modindex', parms[display_y][0][y])
          pfields = [1,0] 
          for key,value in defaults.items():
            if key == 'gr.dur':
              pfields.append(parms[display_x][0][x])
            elif key == 'mod':
              pfields.append(parms[display_y][0][y])
            elif key == 'delay':
              pfields.append(parms[slider1_parm][0][slider1.val])
            elif key == 'gr.pitch':
              pfields.append(parms[slider2_parm][0][slider2.val])
            else:
              pfields.append(value)
          print(pfields)
          cs.scoreEvent("i", pfields)
          #cs.setControlChannel("modindex", parms[display_y][0][y])
          #cs.setControlChannel("graindur", parms[display_x][0][x])
          #print("delay", cs.controlChannel("delay")[1], "gr.pitch", cs.controlChannel("grainpitch")[1])
        old_xy = [x,y]

def on_click(event):
    if (event.inaxes == ax_navigator):
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1
        # NEEDS FIX for the different displaypresets
        png_file = f'./data/{dataset}_gd{int(parms[display_x][0][x]*1000)}_ndx{int(parms[display_y][0][y]*1000)}_dly{int(slider1_data[slider1.val]*1000)}_gp{int(slider2_data[slider2.val])}_cps400_display.png'
        wav_file = f'./data/{dataset}_gd{int(parms[display_x][0][x]*1000)}_ndx{int(parms[display_y][0][y]*1000)}_dly{int(slider1_data[slider1.val]*1000)}_gp{int(slider2_data[slider2.val])}_cps400_partikl.wav'
        print(png_file)
        if not os.path.isfile(png_file):
            partikkelscore = png_file[:-11]+'analyze.sco'
            print(partikkelscore)
            print('running: ', 'csound partikkel_fm_feed_analyze.orc {} -o{} -m0 -d'.format(partikkelscore, wav_file))
            err1 = subprocess.run('csound partikkel_fm_feed_analyze.orc {} -o{} -m0 -d'.format(partikkelscore, wav_file))
            print(wav_file)
            err2 = subprocess.run('python ../spectrogram_and_waveform.py {} {} {} {} {}'.format(png_file[:-12], wav_file, 5000, 400, "nodisplay"))
        platform = sys.platform
        print(platform)
        if platform == 'darwin':
            subprocess.call(('open', png_file))
            subprocess.call(('open', wav_file))
        elif platform in ['win64', 'win32']:
            subprocess.call(('cmd', '/C', 'start', '', png_file))
            subprocess.call(('cmd', '/C', 'start', '', wav_file))

binding_id = plt.connect('motion_notify_event', on_move)
binding_id = plt.connect('axes_enter_event', on_enter)
binding_id = plt.connect('axes_leave_event', on_leave)
plt.connect('button_press_event', on_click)


#ax_checkbox.axis('off')
ax0.axis('off')
plt.show()
csthread.join() 
cs.stop()
cs.reset()
