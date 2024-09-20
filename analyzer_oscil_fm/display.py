
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


def get_timbre_analysis(filename):
    f = open(path+filename, "r")
    timbre_data = []
    for line in f.readlines():
        timbre_data.extend(line.rstrip('\n').split('\t'))
    # timbre_data will hold 10 values dc,crest,centroid, rolloff, pitch, analyzed at two time points in the synthesized sound
    '''dc_amp = float(timbre_data[0][0])
    crest_global = float(timbre_data[0][1])
    centroid = float(timbre_data[0][2])
    rolloff = float(timbre_data[0][3])
    pitch = float(timbre_data[0][4])
    '''
    return timbre_data

# get data
if mode == "saved":
    data = np.load(f"{dataset}_data_array.npy")
else:
    path = f"./data/"
    data = np.ndarray([len(p.modindices), len(p.delays), len(p.am), 8])
    filenum = 0
    numfiles = len(p.modindices) * len(p.delays) * len(p.am)
    for i in range(len(p.modindices)):
        m = p.modindices[i]
        for j in range(len(p.delays)):
            d = p.delays[j]
            for k in range(len(p.am)):
                if filenum%100 == 0:                    
                    print("reading file {} of {}".format(filenum, numfiles))
                am = p.am[k]
                filename = "{}_ndx{}_dly{}_am{}_cps400_analyze.txt".format(dataset, int(m*1000), int(d*1000), int(am))
                timbre_analysis = get_timbre_analysis(filename)
                data[i][j][k] = timbre_analysis
                filenum += 1

    np.save(f"{dataset}_data_array.npy", data,) 

# parameter names and their indices into the data array
parms = {"mod index": [p.modindices,0], 
         "delay": [p.delays,1], 
         "am": [p.am,2]}

# it works best if the parameters displayed on X and Y axis are linearly spaced
displaypreset = 1
if displaypreset == 1:
    display_x = "mod index"
    display_y = "delay"
    slider1_parm = "am"
    #slider2_parm = "grain pitch"
    displaydata = data[:,:,0,0]

slider1_data = parms[slider1_parm][0]
#slider2_data = parms[slider2_parm][0]

# plot axes
fig, ax0 = plt.subplots()
ax = fig.add_axes([0.2, 0.2, 0.8, 0.8],projection='3d')
ax_slider1 = fig.add_axes([0.2, 0.1, 0.6, 0.03])
ax_slider1_val = fig.add_axes([0.81, 0.1, 0.1, 0.03])
#ax_slider2 = fig.add_axes([0.2, 0.05, 0.6, 0.03])
#ax_slider2_val = fig.add_axes([0.81, 0.05, 0.1, 0.03])
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
'''
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
ax_legend.text(0.15, 0.9, "Centroid", dict(size=8))
rect_green = Rectangle((0, 0.7), 0.1, 0.1, color='green')
ax_legend.add_artist(rect_green)
ax_legend.text(0.15, 0.7, "Crest", dict(size=8))
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
        displaydata = data[:,:,slider1.val]
    #elif displaypreset == 2:
    #    displaydata = data[slider1.val,slider2.val,:,:]
    #elif displaypreset == 3:
    #    displaydata = data[slider1.val,:,:,slider2.val]
    # get analysis, must transpose (swap axes)
    dc_amp = np.transpose(displaydata[:,:,2]).ravel()
    crest = np.transpose(displaydata[:,:,3]).ravel()
    centroid = np.transpose(displaydata[:,:,4]).ravel()
    rolloff = np.transpose(displaydata[:,:,5]).ravel()
    pitch = np.transpose(displaydata[:,:,6]).ravel()
    #rolloff /= np.power(sideband_div,0.2) #scale according to number of sidebands
    width = (x_parm[1]-x_parm[0])*0.9
    depth = (y_parm[1]-y_parm[0])*0.9
    colors = np.zeros((len(crest),4))
    red = np.power(dc_amp/max(dc_amp), 0.5) # we use DC relative to sum amp, so it is already normalized
    blue = (np.power((centroid/max(centroid)),1))#*0.9)+0.1
    green = np.power(crest/max(crest), 1) # rollof is relative to sum amp, so it is already normalized
    colors[:,0] = red
    colors[:,1] = green #0.2 # 
    colors[:,2] = blue
    colors[:,3] = 1 # opacity
    ax.bar3d(xx, yy, 0, width, depth, pitch, color=colors, shade=True)
    ax.set_xticks(list(x_parm[i] for i in range(0,len(x_parm),4)))
    ax.set_yticks(list(y_parm[i] for i in range(0,len(y_parm),50)))
    ax.set_xlabel(display_x) 
    ax.set_ylabel(display_y)
    ax.set_zlabel("pitch")
    #ax.set_zlim(200,800)
    ax.set_title('Pitch analysis')
    # sliders
    ax_slider1_val.clear()
    ax_slider1_val.axis('off')
    ax_slider1_val.text(0.1, 0.1, str(parms[slider1_parm][0][slider1.val]))
    #ax_slider2_val.clear()
    #ax_slider2_val.axis('off')
    #ax_slider2_val.text(0.1, 0.1, str(parms[slider2_parm][0][slider2.val]))
    # navigator
    navigator_colors = np.ndarray((len(x_parm),len(y_parm),4))
    for i in range(len(colors)):
        navigator_colors[i%len(x_parm),int(i/len(x_parm))] = colors[i]
    navigator_colors = np.rot90(navigator_colors)
    ax_navigator.imshow(navigator_colors) 
    fig.canvas.draw_idle()

# register the update function with each slider
#slider2.on_changed(update)
slider1.on_changed(update)

update(1)
def on_move(event):
    if (event.inaxes == ax_navigator):
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1

def on_click(event):
    if (event.inaxes == ax_navigator):
        x = round(event.xdata)
        y = len(parms[display_y][0])-round(event.ydata)-1
        # NEEDS FIX for the different displaypresets
        png_file = f'./data/{dataset}_ndx{int(parms[display_x][0][x]*1000)}_dly{int(parms[display_y][0][y]*1000)}_am{int(slider1_data[slider1.val])}_cps400_display.png'
        wav_file = f'./data/{dataset}_ndx{int(parms[display_x][0][x]*1000)}_dly{int(parms[display_y][0][y]*1000)}_am{int(slider1_data[slider1.val])}_cps400_fm.wav'
        print(png_file)
        if not os.path.isfile(png_file):
            score = png_file[:-11]+'analyze.sco'
            print(score)
            print('running: ', 'csound fm_osc_feed_analyze.orc {} -o{} -m0 -d'.format(score, wav_file))
            err1 = subprocess.run('csound fm_osc_feed_analyze.orc {} -o{} -m0 -d'.format(score, wav_file))
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
plt.connect('button_press_event', on_click)
#ax_checkbox.axis('off')
ax0.axis('off')
plt.show()
#runslider = [-1,-1]
#slider_run1.join()
#slider_run2.join()