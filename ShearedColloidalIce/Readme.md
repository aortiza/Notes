# Sheared Colloidal Ice
These are several documents that show the process of analysing the Sheared Colloidal Ice experiments. 
* [CheckingExistingData](CheckingExistingData.ipynb) shows some problems that arose in a previous version of the analysis. 
* [AlignImagesAndLattices](AlignImagesAndLattices.ipynb) shows the manual process of obtaining the alignment parameters to match a colloidal ice object to an array of located particles. 
* [ReanalyseFirstFrames](ReanalyseFirstFrames.ipynb) fixes the problems of [CheckingExistingData](CheckingExistingData.ipynb) in the first frame by retracking the particles using a correlation algorithm, and by filtering out vertices close to the boundaries. 
* [ParticleTracking](ParticleTracking.ipynb) shows the proceess of obtainting a dataset of particle trajectories from all the videos. It uses the correlation algorithm described in [ReanalyseFirstFrames](ReanalyseFirstFrames.ipynb)
