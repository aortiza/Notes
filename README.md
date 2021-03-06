# Details of the Exchange Process

In these notes I review some of the details of how the exchange process occurs, and what are the characteristics of the exchange state. 

## Random Exchange
* [DetailsOfExchangeProcess](DetailsOfExchangeProcess.ipynb) is an exploratory notebook. In it we have some videos of a random exchange state, and we plot several things to look for revelatory data. 
    * The proportion of up and down particles is not half and half due to gravity
    * The MSD shows a strange broken behavior, which could be a transient, but it looks like it has sharp cuts. 
    * The velocity distribution is bimodal, which is consistent with the observed behavior. Particles undergoing exchange process are very fast compared with particles in the bulk. 
    * From this we can divide the system in two subsets, fast particles and slow particles. 
    * Looking at the radial distribution function, the slow particles seem to form a liquid whereas the fast particles look like a gas
    
## Directional Exchange
### Run simulations and Preprocess
* [DirectionalExchange SweepParameters](DirectionalExchange_SweepParameters.ipynb) we used this notebook to run the simulations of the phase diagram. It sweeps frequency with time, and it runs for several tilts. We did simulations at $h=3.5\mu{}m$ and $h=3.9\mu{}m$
* [CalculateVelocities_UpDown](CalculateVelocities_UpDown.ipynb) after running the simulations it is necessary to calculate the order parameters. Most of the order parameters we are observing can be retrieved from the *differentiated velocity* which averages the velocity of all particles and all times, but separates velocities for *up* and *down* particles. 
* [DensityDependence Run Simulations](DensityDependence_RunSimulations.ipynb) We ran simulations for different packing fractions to look for some type of jamming.  
* [DensityDependence Calculate Velocities](DensityDependence_CalculateVelocities.ipynb) For these simulations we also had to calculate the differentiated velocity.
### Data visualizations
* [Current Phase Diagram](Current_PhaseDiagram.ipynb) This notebook uses the data from the *differentiated velocity* and creates a phase diagram of different states characterized by the *current* order parameter. For the $h = 3.9\mu{}m$ case we compare it with the data of the model and find an agreement. 
* [Current Angle](Current_Angle.ipynb) Here we analyze the angle of the current relative to the angle of the tilt. 
* [Velocity vs Delta](VelocityVsDelta.ipynb) From the [Current Angle](Current_Angle.ipynb) we obtain a director vector, and then we plot the dependence of the velocity with the tilt. 
* [Current vs Density] (CurrentVsDensity.ipynb) This uses the data of [DensityDependence Run Simulations](DensityDependence_RunSimulations.ipynb) to produce a plot of the density dependence of the current. We observe that in the range $\Phi\in[0.4,0.6]$ the current decreases monotonically with the density, until it becomes zero at $\Phi=0.6$. I believe this is a type of jamming, but it's mechanism must be different from granular matter jamming. 