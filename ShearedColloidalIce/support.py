import numpy as np
import pandas as pd
idx = pd.IndexSlice

def match_colloid_frame(col,trj_frame):
    
    for c in col:
        d = np.sqrt((trj_frame.x-c.center[0].magnitude)**2 + (trj_frame.y-c.center[1].magnitude)**2)
        closest = d.idxmin()
        closest_part = trj_frame.loc[idx[closest],:]
        units = c.center.units
        c.colloid = [(closest_part.x-c.center[0].magnitude),(closest_part.y-c.center[1].magnitude),0]*units
        if c.direction@c.colloid<0:
            c.direction = -c.direction

def vertices_array_to_pd(vertices):
    vert_pd = pd.DataFrame(data = vertices.array["Coordination"],
                        index = vertices.array["id"],
                        columns = ["Coordination"])
    
    vert_pd["Charge"] = vertices.array["Charge"]
    vert_pd["DipoleX"] = vertices.array["Dipole"][:,0]
    vert_pd["DipoleY"] = vertices.array["Dipole"][:,1]

    vert_pd["LocationX"] = vertices.array["Location"][:,0]
    vert_pd["LocationY"] = vertices.array["Location"][:,1]

    vert_pd.index.name = "id"
    
    return vert_pd

def vertices_pd_to_array(vertices,v_pd):
    vertices.array["Coordination"][v_pd.index] = v_pd.Coordination
    vertices.array["Charge"][v_pd.index] = v_pd.Charge
    vertices.array["Dipole"][v_pd.index] = v_pd[["DipoleX","DipoleY"]]
    vertices.array["Location"][v_pd.index] = v_pd[["LocationX","LocationY"]]