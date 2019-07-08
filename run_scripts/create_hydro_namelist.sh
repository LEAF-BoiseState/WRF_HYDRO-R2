#
# create_hydro_namelist.sh - create hydro.namelist with routing parameters, etc.
# matt masarik 
# 7 jul 2019 
# 
# (0) LSM - NOAHMP LAND SURFACE
# (1) SUB - SUBSURFACE
# (2) OVR - OVERLAND
# (3) CHL - CHANNEL
# (4) RES - LAKE / RESERVOIR
# (5) GWB - GROUNDWATER / BASEFLOW
#



# ----------------------------------------------------------------------------- *
#                      GENERAL SIMULATION PARAMETERS
# ----------------------------------------------------------------------------- *
# Specify the restart file write frequency...(minutes)
# A value of -99999 will output restarts on the first day of the month only.
rst_dt=9999       

# Reset the LSM soil states from the high-res routing restart file 
# (1=overwrite, 0=no overwrite)
# NOTE: Only turn this option on if overland or subsurface rotuing is active!
rst_typ=0

# Netcdf grid of variables passed between LSM and routing components (2d)
# (0 = no output, 1 = output)
# NOTE: No scale_factor/add_offset available
LSMOUT_DOMAIN=1

# Netcdf grid of terrain routing variables on routing grid (2d):
# (0 = no output, 1 = output)
RTOUT_DOMAIN=1

# ASCII text file of forecast points or gage points (defined in Routelink):
# (0 = no output, 1 = output)
frxst_pts_out=1

# Specify the grid spacing of the terrain routing grid...(meters)
DXRT=250.0

# Integer multiple between land model grid and terrain routing grid...(integer)
AGGFACTRT=4

# Specify the terrain routing model timestep...(seconds)
DTRT_TER=10







# ----------------------------------------------------------------------------- *
#                      (0) LSM - NOAHMP LAND SURFACE
# ----------------------------------------------------------------------------- *





# ----------------------------------------------------------------------------- *
#                      (1) SUB - SUBSURFACE
# ----------------------------------------------------------------------------- *
# Switch to activate subsurface routing:
# (0=no, 1=yes)
SUBRTSWCRT=0




# ----------------------------------------------------------------------------- *
#                      (2) OVR - OVERLAND
# ----------------------------------------------------------------------------- *
# Switch to activate surface overland flow routing:
# (0=no, 1=yes)
OVRTSWCRT=1

# Specify overland flow routing option:
# (1=Steepest Descent - D8, 2=CASC2D - not active)
# NOTE: Currently subsurface flow is only steepest descent
rt_option=1




# ----------------------------------------------------------------------------- *
#                      (3) CHL - CHANNEL
# ----------------------------------------------------------------------------- *
# Switch to activate channel routing:
# (0=no, 1=yes)
CHANRTSWCRT=1

# Specify channel routing option:
# (1=Muskingam-reach, 2=Musk.-Cunge-reach, 3=Diff.Wave-gridded)
channel_option=3

# Specify the channel routing model timestep...(seconds)
DTRT_CH=10

# Netcdf point timeseries output at all channel points (1d):
# (0 = no output, 1 = output)
CHRTOUT_DOMAIN=1

# Netcdf point timeseries at forecast points or gage points (defined in Routelink):
# (0 = no output, 1 = output at forecast points or gage points.)
CHANOBS_DOMAIN=1

# Netcdf grid of channel streamflow values (2d):
# (0 = no output, 1 = output)
# NOTE: Not available with reach-based routing
CHRTOUT_GRID=1




# ----------------------------------------------------------------------------- *
#                      (4) RES - LAKE / RESERVOIR
# ----------------------------------------------------------------------------- *
# Netcdf grid of lake values (1d):
# (0 = no output, 1 = output)
outlake=0




# ----------------------------------------------------------------------------- *
#                      (5) GWB - GROUNDWATER / BASEFLOW
# ----------------------------------------------------------------------------- *
# Switch to activate baseflow bucket model:
# (0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT=0

# Specify baseflow/bucket model initialization:
# (0=cold start from table, 1=restart file)
GW_RESTART=0

# Netcdf GW output:
# (0 = no output, 1 = output)
output_gw=0



