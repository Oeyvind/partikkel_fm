import cv2
from PIL import Image
from skimage import io
import numpy as np

IMAGE_WIDTH = 200
IMAGE_HEIGHT = 200

def create_collage(images,xy_size):
    images = [io.imread(img) for img in images]
    images = [cv2.resize(image, (IMAGE_WIDTH, IMAGE_HEIGHT)) for image in images]
    x_size, y_size = xy_size
    output = cv2.hconcat(images[0:x_size])
    for i in range(1,y_size):
        h1 = cv2.hconcat(images[x_size*i:x_size*(i+1)])
        output = cv2.vconcat([output, h1])
    image = Image.fromarray(output)

    # Image path
    image_name = "navigator_collage_dly_pitch.png"
    image = image.convert("RGB")
    image.save(f"{image_name}")
    return image_name

p = ''
dataset = 'full'
get_parameters = f"import {dataset}_parametervalues as p"
exec(get_parameters)
images = []
for d in p.modindices: # just kludging it together (wrong filenames exported from display)
    for gp in p.graindurs:
        fname = f"./figexport/navigatorfig_dly{int(d*1000)}_gp{gp}.png"
        print(fname)
        images.append(fname)
xy_size = (len(p.grainpitches), len(p.delays))
create_collage(images, xy_size)

