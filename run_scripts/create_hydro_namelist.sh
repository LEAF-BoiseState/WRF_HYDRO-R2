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
# NOTES:  
#   * Terrain routing = Overland flow routing, and/or Subsurface flow routing
#


# PARAMETERS - DEFAULT / USER
DX_LSM_METERS=1000                  # Land Surface Model grid spacing    [meters]
DX_ROUTING_TERRAIN_METERS=250       # Terrain Routing Model grid spacing [meters]
DT_ROUTING_TERRAIN_SECONDS=10       # Terrain Routing Model timestep    [seconds]
DT_ROUTING_CHANNEL_SECONDS=10       # Channel Routing Model timestep    [seconds]





# USER INPUT ARGS
routing_options=""
routing_options_flag="false"
num_routing_options=0
hydro_namelist_path=""
if [[ "$#" -lt 1 || "$#" -gt 7 ]]; then
    prog=$(basename $0)
    echo -e "\n\tUSAGE: $prog <hydro_namelist> [<0 ... 5>]\n"
    exit 1
else
    hydro_namelist_path="$1"
    shift
    routing_options="$*"
    num_routing_options=$#
    routing_options_flag="true"
fi



# Set flag / display routing components from user input
SUB_FLAG=0                   # 1 SUB: Subsurface
OVR_FLAG=0                   # 2 OVR: Overland
CHL_FLAG=0                   # 3 CHL: Channel
RES_FLAG=0                   # 4 RES: Lakes / Reservoirs
GWB_FLAG=0                   # 5 GWB: Groundwater / Base flow
echo -e "\n\tROUTING OPTIONS"
echo -e   "\t---------------"
echo -e "\t  0:   LSM          -  NoahMP Land Surface Model [selected by default]"
if [ "$routing_options_flag" == "true" ]; then

    for ro in $routing_options
    do
	if   [ $ro -eq 0 ]; then
            : # null op, 0 is default selected
	elif [ $ro -eq 1 ]; then
            SUB_FLAG=1
            echo -e "\t  1:   SUB          -  Subsurface Flow Routing"
	elif [ $ro -eq 2 ]; then
            OVR_FLAG=1
            echo -e "\t  2:   OVR          -  Overland Flow Routing"
	elif [ $ro -eq 3 ]; then
            CHL_FLAG=1
            echo -e "\t  3:   CHL          -  Channel Routing"
	elif [ $ro -eq 4 ]; then
            RES_FLAG=1
        echo -e "\t  4:   RES          -  Lakes/Reservoir Routing"
	elif [ $ro -eq 5 ]; then
            GWB_FLAG=1
        echo -e "\t  5:   GWB          -  Groundwater/baseflow Routing"
        else
            echo -e "\t  ** ${ro}:   BAD VALUE   - Valid opts: 0-5. **"
        fi
    done
    echo -e "\n"
fi
echo -e "\thydro.namelist path: $hydro_namelist_path\n"


# ----------------------------------------------------------------------------- *
#                      GENERAL SIMULATION PARAMETERS
# ----------------------------------------------------------------------------- *
# Specify the restart file write frequency...(minutes)
# A value of -99999 will output restarts on the first day of the month only.
rst_dt=-99999       



# ----------------------------------------------------------------------------- *
#                      (0) LSM - NOAHMP LAND SURFACE
# ----------------------------------------------------------------------------- *
# Netcdf grid of variables passed between LSM and routing components (2d)
# (0 = no output, 1 = output)
# NOTE: No scale_factor/add_offset available
LSMOUT_DOMAIN=1



# ----------------------------------------------------------------------------- *
#                      (0.5) TERRAIN - SUBSURFACE / OVERLAND
# ----------------------------------------------------------------------------- *
lsm_rst_type=0                            
terrain_routing_grid_output=0
if [[ $SUB_FLAG -eq 1 ]] || [[ $OVR_FLAG -eq 1 ]]; then
    lsm_rst_type=1
    terrain_routing_grid_output=1
fi

# Reset the LSM soil states from the high-res routing restart file 
# (1=overwrite, 0=no overwrite)
# NOTE: Only turn this option on if overland or subsurface rotuing is active!
rst_typ=$lsm_rst_type

# Netcdf grid of terrain routing variables on routing grid (2d):
# (0 = no output, 1 = output)
RTOUT_DOMAIN=$terrain_routing_grid_output

# Specify the terrain routing model timestep...(seconds)
DTRT_TER=$DT_ROUTING_TERRAIN_SECONDS

# Specify the grid spacing of the terrain routing grid...(meters)
DXRT=$DX_ROUTING_TERRAIN_METERS

# Created parameter, grid spacing of the LSM grid (meters), file: geo_em.d0x.nc
# NOTE: this is along with DXRT to calculate AGGFACTRT
DXLSM=$DX_LSM_METERS

# Integer multiple between land model grid and terrain routing grid...(integer)
AGGFACTRT=$(( DXLSM / DXRT ))





# ----------------------------------------------------------------------------- *
#                      (1) SUB - SUBSURFACE
# ----------------------------------------------------------------------------- *
subrtswcrt_val=0
if [ $SUB_FLAG -eq 1 ]; then
    subrtswcrt_val=1
fi

# Switch to activate subsurface routing:
# (0=no, 1=yes)
SUBRTSWCRT=$subrtswcrt_val




# ----------------------------------------------------------------------------- *
#                      (2) OVR - OVERLAND
# ----------------------------------------------------------------------------- *
ovrtswcrt_val=0
if [ $OVR_FLAG -eq 1 ]; then
    ovrtswcrt_val=1
fi

# Switch to activate surface overland flow routing:
# (0=no, 1=yes)
OVRTSWCRT=$ovrtswcrt_val

# Specify overland flow routing option:
# (1=Steepest Descent - D8, 2=CASC2D - not active)
# NOTE: Currently subsurface flow is only steepest descent
rt_option=1




# ----------------------------------------------------------------------------- *
#                      (3) CHL - CHANNEL
# ----------------------------------------------------------------------------- *
chanrtswcrt_val=0
chrtout_domain_val=0
chanobs_domain_val=0
frxst_pts_out_val=0
if [ $CHL_FLAG -eq 1 ]; then
    chanrtswcrt_val=1
    chrtout_domain_val=1
    chanobs_domain_val=1
    frxst_pts_out_val=1
fi


# Switch to activate channel routing:
# (0=no, 1=yes)
CHANRTSWCRT=$chanrtswcrt_val

# Specify channel routing option:
# (1=Muskingam-reach, 2=Musk.-Cunge-reach, 3=Diff.Wave-gridded)
channel_option=3

# Specify the channel routing model timestep...(seconds)
DTRT_CH=$DT_ROUTING_CHANNEL_SECONDS

# Netcdf point timeseries output at all channel points (1d):
# (0 = no output, 1 = output)
CHRTOUT_DOMAIN=$chrtout_domain_val

# Netcdf point timeseries at forecast points or gage points (defined in Routelink):
# (0 = no output, 1 = output at forecast points or gage points.)
CHANOBS_DOMAIN=$chanobs_domain_val

# Netcdf grid of channel streamflow values (2d):
# (0 = no output, 1 = output)
# NOTE: Not available with reach-based routing
chrtout_grid_val=0
if [[ $CHL_FLAG -eq 1 ]] && [[ $channel_option -eq 3 ]]; then
    chrtout_grid_val=1
fi
CHRTOUT_GRID=$chrtout_grid_val

# ASCII text file of forecast points or gage points (defined in Routelink):
# (0 = no output, 1 = output)
frxst_pts_out=$frxst_pts_out_val




# ----------------------------------------------------------------------------- *
#                      (4) RES - LAKE / RESERVOIR
# ----------------------------------------------------------------------------- *
outlake_val=0
if [ $RES_FLAG -eq 1 ]; then
    outlake_val=1
fi

# Netcdf grid of lake values (1d):
# (0 = no output, 1 = output)
outlake=$outlake_val




# ----------------------------------------------------------------------------- *
#                      (5) GWB - GROUNDWATER / BASEFLOW
# ----------------------------------------------------------------------------- *
gwbaseswcrt_val=0
output_gw_val=0
if [ $GWB_FLAG -eq 1 ]; then
    gwbaseswcrt_val=1               # [1, 2] default=1 (exp. bucket)
    output_gw_val=1
fi
gw_restart_val=0                    # [0, 1] default=0 (cold start from tbl)

# Switch to activate baseflow bucket model:
# (0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT=$gwbaseswcrt_val        # default=1, exp bucket, when gwb on

# Specify baseflow/bucket model initialization:
# (0=cold start from table, 1=restart file)
GW_RESTART=$gw_restart_val          # default=0, cold start from tbl, when gwb on

# Netcdf GW output:
# (0 = no output, 1 = output)
output_gw=$output_gw_val



# ----------------------------------------------------------------------------- *
#                     MAIN - CREATE HYDRO.NAMELIST
# ----------------------------------------------------------------------------- *
sed -i'' "s/rstdt/$rst_dt/g"                   $hydro_namelist_path
sed -i'' "s/lsmoutdomain/$LSMOUT_DOMAIN/g"     $hydro_namelist_path
sed -i'' "s/lsmrsttype/$rst_typ/g"             $hydro_namelist_path
sed -i'' "s/rtoutdomain/$RTOUT_DOMAIN/g"       $hydro_namelist_path
sed -i'' "s/dtrtter/$DTRT_TER/g"               $hydro_namelist_path
sed -i'' "s/dxrt/$DXRT/g"                      $hydro_namelist_path
sed -i'' "s/aggfactrt/$AGGFACTRT/g"            $hydro_namelist_path
sed -i'' "s/subrtswcrt/$SUBRTSWCRT/g"          $hydro_namelist_path
sed -i'' "s/ovrtswcrt/$OVRTSWCRT/g"            $hydro_namelist_path
sed -i'' "s/rtoption/$rt_option/g"             $hydro_namelist_path
sed -i'' "s/chanrtswcrt/$CHANRTSWCRT/g"        $hydro_namelist_path
sed -i'' "s/channeloption/$channel_option/g"   $hydro_namelist_path
sed -i'' "s/dtrtch/$DTRT_CH/g"                 $hydro_namelist_path
sed -i'' "s/chrtoutdomain/$CHRTOUT_DOMAIN/g"   $hydro_namelist_path
sed -i'' "s/chanobsdomain/$CHANOBS_DOMAIN/g"   $hydro_namelist_path
sed -i'' "s/chrtoutgrid/$CHRTOUT_GRID/g"       $hydro_namelist_path
sed -i'' "s/frxstptsout/$frxst_pts_out/g"      $hydro_namelist_path
sed -i'' "s/outlakeval/$outlake/g"             $hydro_namelist_path
sed -i'' "s/gwbaseswcrt/$GWBASESWCRT/g"        $hydro_namelist_path
sed -i'' "s/gwrestart/$GW_RESTART/g"           $hydro_namelist_path
sed -i'' "s/outputgw/$output_gw/g"             $hydro_namelist_path

exit
