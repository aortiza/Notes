import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import scipy as sp
from pims import pipeline

def simulated_particle(diameter, ratio = 1.25,thick_ratio = 0.25):
	"""Returns a simulated template particle by evaluating a Gaussian function on a ring."""
	width = round(1.25*diameter)
	thickness = thick_ratio*diameter
	x = np.linspace(-1/2,1/2,width+1)*width
	X,Y = np.meshgrid(x,x)
	R = np.sqrt(X**2+Y**2)
	custom_filter = -np.exp(-(R-diameter/2)**2/2/thickness)
	return custom_filter/np.abs(np.sum(custom_filter))
	
def subimage_particle(image,location,diameter, ratio = 1.25):
	""" Clips a subimage centered at location to use as a template particle"""
	print(diameter)
	w = int(round(ratio*diameter))
	print(w)
	location = np.round(location).astype("uint32")
	
	test_image = image[
		location[1]-round(w/2):location[1]+round(w/2),
		location[0]-round(w/2):location[0]+round(w/2),:]
	test_image = test_image-np.mean(test_image)

	return test_image/np.abs(np.sum(test_image))
	
def visualize_template(template,diameter = None, ax=None, cbar=False):
	"""Plots a template and adds a ring to visualize the diameter"""
	if ax is None:
		fig, ax = plt.subplots(1,1,figsize=(2,2), dpi=150)
	else:
		fig = ax.figure
		
	im = ax.imshow(template,cmap="gray")
	if cbar:
		fig.colorbar(im)
		
	if diameter is not None:
		w = len(template)
		ax.add_patch(mpl.patches.Circle([(w-1)/2,(w-1)/2],radius=diameter/2,fill=False,edgecolor="red"))

def template_convolve(image,template):
	fl_sim_image = sp.ndimage.convolve(image,template)
	return (fl_sim_image - np.min(fl_sim_image))*255/(np.max(fl_sim_image)-np.min(fl_sim_image))