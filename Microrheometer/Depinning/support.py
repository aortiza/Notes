import os
import sys
import re

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy.spatial as spa
import scipy.optimize as spo
import trackpy as tp
import pims
import copy as cp

# Convert from dense to pandas array
idx = pd.IndexSlice

def dense2multiindex(trj_dat):
    no_of_col = trj_dat.shape[1]
    no_of_part = round((no_of_col-1)/2)
    
    times = trj_dat[0].values
    indexes = np.arange(0,no_of_part)
    
    index = pd.MultiIndex.from_product([times,indexes],names=('time','id'))
    
    trj = pd.DataFrame(
        {"x":trj_dat.iloc[:,1::2].values.flatten(),
         "y":trj_dat.iloc[:,2::2].values.flatten()},index=index)
    return trj
# load .dat and convert
def load_dat(name):
    date_parser = lambda time : pd.to_datetime(
        float(time)+2*3600, unit="s", origin=pd.Timestamp('1904-01-01'))
    
    trj_dat = pd.read_csv(name+'.dat',sep="\t",
                header=None, parse_dates=[0], date_parser=date_parser)
    
    trj = dense2multiindex(trj_dat)

    trj["time"] = trj.index.get_level_values("time")
    trj["name"] = os.path.split(name)[-1]
    trj["id"] = trj.index.get_level_values("id")
    
    trj = trj.set_index(["name","time","id"])
    
    return trj
 
def drop_first_frame(trj):

    t0 = trj.index.get_level_values("time").unique().values[0]
    trj = trj.drop(trj.loc[idx[t0,:],:].index)
    return trj

def draw_trj(trj):
    for i in trj.index.get_level_values("id").unique():
        plt.plot(trj.loc[idx[:,:,i],:].x,trj.loc[idx[:,:,i],:].y)
    plt.axis('equal');
    
def obtain_boundary(trj):
    t0 = trj.index.get_level_values("time").unique().values[0]
    Delaunay = spa.Delaunay(trj.loc[idx[t0,:],:].values)
    boundary = list(np.unique(Delaunay.convex_hull.flatten()))
    boundary = list(trj.loc[idx[t0,:],:].index.get_level_values("id").values[boundary])
    return boundary
    
def get_center(trj):
    
    def calc_R(xc, yc):
        """ calculate the distance of each 2D points from the center (xc, yc) """
        return np.sqrt((trj.x.values-xc)**2 + (trj.y.values-yc)**2)

    def f_2(c):
        """ calculate the algebraic distance between the data points and the mean circle centered at c=(xc, yc) """
        Ri = calc_R(*c)
        return Ri - Ri.mean()    

    center_estimate = 0, 0
    center, ir = spo.leastsq(f_2, center_estimate)
    return center

def layers(trj):
    
    def next_layer(trj):
        t0 = trj.index.get_level_values("time").unique().values[0]
        boundary = obtain_boundary(trj.loc[idx[t0,:],:].filter(["x","y"]))
        trj2 = trj.drop(trj.loc[idx[t0,list(boundary)],:].index).loc[idx[t0,:],:].filter(["x","y"]).copy()
        return trj2, boundary
    
    layers = []

    while not trj.empty:
        trj, layer = next_layer(trj)
        layers.append(layer)

    return layers

def find_trimer(trj):
    trj["r"] = np.sqrt(trj.x**2+trj.y**2)
    trimer = trj.groupby("id").r.mean().sort_values().index[0:3]
    trimer = trj.loc[idx[:,trimer],:].copy()
    return trimer

def calculate_polar(trj):
    trj["r"] = np.sqrt(trj.x**2+trj.y**2)
    trj["theta"] = (np.arctan2(trj.y,trj.x))
    def unwrap(p):
        p.iloc[:] = np.unwrap(p)
        return p

    trj.theta = trj.theta.groupby("id").apply(unwrap)
    return trj
    
def calculate_velocities(trj):
    times = trj.index.get_level_values("time").values.astype(float)*1e-9
    
    trj["rel_time"] = times - times[0]
    velocities = trj.groupby("id").diff()
    
    trj["vx"]=velocities.x/velocities.rel_time
    trj["vy"]=velocities.y/velocities.rel_time
    trj["vr"]=velocities.r/velocities.rel_time
    trj["vth"] = velocities.theta*trj.r/velocities.rel_time
    trj["omega"] = velocities.theta/velocities.rel_time
    return trj

def get_names(directory,ext='.dat'):

    base_names = [os.path.join(root,os.path.splitext(file)[0]) 
              for root, dirs, files in os.walk(directory) 
              for file in files 
              if file.endswith(ext)]
    base_names = list(np.sort(np.array(base_names)))
    return base_names 
    
def frame_to_time_index(trj):

    trj["name"] = trj.index.get_level_values("name")
    trj["id"] = trj.index.get_level_values("id")
    trj["frame"] = trj.index.get_level_values("frame")
    trj = trj.set_index(["name","time","id"])
    return trj 

def from_px_to_um(trj,px_size):
    trj.x = trj.x*px_size # microns per pixel
    trj.y = trj.y*px_size # microns per pixel
    return trj

def add_layers(trj,frame=None):
	names = trj.index.get_level_values("name").unique()
	
	for n in names:
		times = trj.loc[idx[n,:,:],:].index.get_level_values("time").unique()
		
		if frame is None:
			# Weird Recursivity. 
			# If frame is none, start at zero. 
			# If Qhull error appears, increase the frame until it doesnt. 
			# In each step, the function calls itself with a frame value. 
			# When the function is called with a value, it should not iterate (next case).
			
			found = False
			frame = 0
			while not found:
				try:
					trj = add_layers(trj,frame=frame)
					found = True
				except spa.qhull.QhullError:
					frame = frame + 1
			frame = None
			
		else:
			
			layer_indexes = layers(
				trj.loc[idx[n,times[frame],:],:].reset_index(level=0,drop=True))
			
			for i,l in enumerate(layer_indexes):
				trj.loc[idx[n,:,layer_indexes[i]],"layer"] = i
	
	return trj

def recenter(trj):
    center = get_center(trj[trj.layer==0])
    trj.x+=-center[0]
    trj.y+=-center[1]
    return trj

    
def field_values(trj,field):

    times = trj.index.get_level_values("time").unique()
    
    field_re = field.reindex(field.index.append(times).sort_values()).ffill()
    field_re = field_re[~field_re.index.duplicated(keep='first')]
    field_re = field_re.loc[trj.index.get_level_values("time")[:]].X_Amplitude
    
    trj["field"] = field_re.values
    return trj

def assign_direction(trj):
    time_direction = (trj.groupby("time").mean().field**2).diff()
    time_direction[time_direction == 0] = np.NaN
    time_direction = time_direction.fillna(method="ffill")
    time_direction = np.sign(time_direction)

    direction_str = cp.deepcopy(time_direction)
    direction_str[time_direction > 0] = "fwd"
    direction_str[time_direction < 0] = "bwd"
    
    trj["direction"] = direction_str[trj.index.get_level_values("time")].values
    
    return trj