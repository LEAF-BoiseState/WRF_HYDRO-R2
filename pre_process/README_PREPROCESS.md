# README_CONVERT.md


## I. Overview
For the available WRF output data the conversion process consists of two steps.  First, subsetting in time and field variables.  WRF-Hydro input 
is required to be in the format of 1 time step per file.  Additionally, WRF-Hydro only needs a small subset of the surface variables that
are in the standard WRF output.  The subsetting process takes care of these two requirements by extracting each time step into a single file 
containing the necessary subset of variables.  The second step is regridding the WRF domain to the WRF-Hydro domain.  This regridding takes 
care of the domain extent as well as resolution.

