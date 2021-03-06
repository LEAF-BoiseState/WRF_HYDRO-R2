#!/bin/bash

# *****************************************************************************
# FILE:     wrf_hydro_run_funcs.sh
# AUTHOR:   Matt Masarik      (MM) 
# VERSION:  0     2019-06-24   MM    Base version
#
# PURPOSE:  set of functions to simplify building and run related tasks.
#
# USAGE:    source wrf_hydro_run_funcs.sh
#
# CONTENTS:
#   (1)  wh_dev          <queue_name> <minutes>                     # slurm request interactive compute session
#
#   (2)  wh_sub_mod                                                 # init/update submodules
#   (3)  wh_build_nwm                                               # compile wrf-hydro/nwm executable
#   (4)  wh_clean_nwm                                               # clean out nwm build 
#
#   (5)  wh_run_dir      <run_id>                                   # create run directory, copy exe + aux files
#   (6)  wh_domain       <run_id> <domain_id>                       # copy cutout to DOMAIN/
#   (7)  wh_forcing      <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING/
#   (8)  wh_hydro_nlist  <run_id> [<0 ... 5>]                       # create hydro.namelist w routing opts
#   (9)  wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours> # create namelist.hrldas w simulation period
#  (10)  wh_job          <run_id> <queue_name> <minutes> <cores>    # create batch job submit script
#
#  (11)  wh_list                                                    # list wrf-hydro defined functions
#  (12)  wh_list_domain                                             # list wrf-hydro cutout domains
#  (13)  wh_list_routing                                            # list routing/physics options
# *****************************************************************************


# USER PARAMETERS
RUN_DIR_BASE="/scratch/${USER}/WH_SIM"



# -------------------------------- FIXED PARAMETERS ---------------------------------
WH_R2_FUNCS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WH_R2_REPO=${WH_R2_FUNCS_DIR%/*}                                                   
NWM_BUILD_DIR=$WH_R2_REPO/wrf_hydro_nwm_public/trunk/NDHMS
NWM_BUILD_RUN_DIR=$NWM_BUILD_DIR/Run
CONVERT_W2WH=$WH_R2_REPO/pre_process/convert_wrf_to_wrfhydro.sh
EXE=wrf_hydro_NoahMP.exe


# cutouts
NUM_CUTOUTS=8
IDAHO_CUTOUTS=/scratch/leaf/WRF-Hydro/cutouts
CUTOUT1=13139510
CUTOUT1_DESC="Big Wood River at Hailey ID"
CUTOUT2=13168500
CUTOUT2_DESC="Bruneau River near Hot Springs ID"
CUTOUT3=13185000
CUTOUT3_DESC="Boise River near Twin Springs ID"
CUTOUT4=13186000
CUTOUT4_DESC="SF Boise River near Featherville ID"
CUTOUT5=13235000
CUTOUT5_DESC="SF Payette River at Lowman ID"
CUTOUT6=13237920
CUTOUT6_DESC="MF Payette River near Crouch ID"
CUTOUT7=13258500
CUTOUT7_DESC="Weiser River near Cambridge ID"
CUTOUT8=13316500
CUTOUT8_DESC="Little Salmon River at Riggins ID"



# (1)  wh_dev  <queue_name> <minutes>      # slurm request interactive compute session
function wh_dev() {
    local session_id='WRFHYDEV'
    local let MAXMINS=60

    if [ $# -ne 2 ]; then
        echo -e "\n\tUSAGE: wh_dev <queue_name> <minutes>\n"
        return
    elif [[ $2 -le 0 || $2 -gt $MAXMINS ]]; then
        echo -e "\n\tUSAGE: wh_dev <queue_name> <minutes>"
        echo -e   "\t\twhere, 0  <  <minutes>  <=  60.\n"
        return
    fi
    local queue_name="$1"
    local sim_mins=${2#0}
    local smins_0pad=""
    if [ $sim_mins -lt 10 ]; then
        smins_0pad="0$sim_mins"
    else
        smins_0pad="$sim_mins"
    fi

    local job_string="\"$session_id\" -t 00:${smins_0pad}:00 -p $queue_name -n 1 --pty /bin/bash"
    echo "srun -J $job_string"
    srun -J $job_string
    return
}



# (2) wh_sub_mod                     # init/update submodules
function wh_sub_mod() {
    local start_dir=$(pwd)
    cd $WH_R2_REPO
    git submodule init
    git submodule update
    cd $start_dir
    return
}



# (3) wh_build_nwm                             # compile wrf-hydro/nwm executable
function wh_build_nwm() {
    $WH_R2_REPO/build/build_nwm_r2.sh
    return
}



# (4) wh_clean_nwm                                              # clean out nwm build 
function wh_clean_nwm() {
    if [ -d $NWM_BUILD_DIR/Run         ]; then rm -vrf $NWM_BUILD_DIR/Run;        fi
    if [ -f $NWM_BUILD_DIR/setEnvar.sh ]; then rm -vf $NWM_BUILD_DIR/setEnvar.sh; fi
    if [ -f $NWM_BUILD_DIR/macros.orig ]; then rm -vf $NWM_BUILD_DIR/macros.orig; fi
    return
}



# (5) wh_run_dir    <run_id>                    # create run directory, copy exe + aux files
function wh_run_dir() {
    if [ $# -ne 1 ]; then
        echo -e "\n\tUSAGE: wh_run_dir <run_id>\n"
        return
    fi
    if [ ! -d $NWM_BUILD_DIR/Run ]; then
        echo -e "NWM build executable directory, $NWM_BUILD_DIR/Run, does not exist."
        echo -e "Run, wh_build_nwm, then re-run, wh_run_dir.\n"
        return
    fi
    local run_id="$1"
    local run_dir_path=${RUN_DIR_BASE}_$run_id
    if [ -d $run_dir_path ]; then
        echo -e "\nRun directory already exists."
    else
        echo -e "\nCreating run directory..."
        mkdir -p $run_dir_path
    fi
    echo -e "\tDirectory: $run_dir_path.\n"

    cp $WH_R2_REPO/build/env_nwm_r2.sh   $run_dir_path
    cp $NWM_BUILD_RUN_DIR/*              $run_dir_path
    mv $run_dir_path/hydro.namelist      $run_dir_path/hydro.namelist.build
    mv $run_dir_path/namelist.hrldas     $run_dir_path/namelist.hrldas.build
    return
}



# (6) wh_domain     <run_id> <domain_id>                        # copy cutout to DOMAIN/
function wh_domain() {
    if   [ $# -ne 2 ]; then 
        echo -e "\n\tUSAGE: wh_domain <run_id> <domain_id>\n"
        return
    elif [[ $2 -lt 1 || $2 -gt $NUM_CUTOUTS ]]; then
        echo -e "\n\tUSAGE: wh_domain <run_id> <domain_id>"
        echo -e   "\t\twhere, 1 <= <domain_id> <= $NUM_CUTOUTS.\n"
        return
    fi
    local run_id="$1"
    local dom_id=$2
    local run_dir_path=${RUN_DIR_BASE}_$run_id
    if [ ! -d ${RUN_DIR_BASE}_$run_id ]; then
        echo -e "\n\tRun directory does not exist: $run_dir_path.\n"
        return
    fi

    if   [ $dom_id -eq 1 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT1 - $CUTOUT1_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT1/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 2 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT2 - $CUTOUT2_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT2/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 3 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT3 - $CUTOUT3_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT3/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 4 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT4 - $CUTOUT4_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT4/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 5 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT5 - $CUTOUT5_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT5/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 6 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT6 - $CUTOUT6_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT6/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 7 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT7 - $CUTOUT7_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT7/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    elif [ $dom_id -eq 8 ]; then
	echo  -e "\n\t$dom_id:  $CUTOUT8 - $CUTOUT8_DESC"
	mkdir -p $run_dir_path/DOMAIN
	cp    -r $IDAHO_CUTOUTS/$CUTOUT8/* $run_dir_path/DOMAIN
	echo  -e "\tDomain directory has been created: $run_dir_path/DOMAIN.\n"
    else
        echo  -e "\nInvalid domain ID, dom_id == $dom_id.\n"
        return
    fi
    return
}



# (7) wh_forcing    <run_id> <input_dir> <geogrid_file>         # subset + regrid forcing to FORCING/
function wh_forcing() {
    if [ $# -ne 3 ]; then
        echo -e "\n\tUSAGE: wh_forcing <run_id> <input_dir> <geogrid_file>\n"
        return
    fi
    local run_id="$1"
    local input_dir="$2"
    local geogrid_file="$3"

    if [ ! -d ${RUN_DIR_BASE}_${run_id} ]; then
        echo -e "\nInvalid run directory, ${RUN_DIR_BASE}_${run_id}, for <run_id> = $run_id.\n"
        return
    fi
    if [ ! -d $input_dir ]; then
        echo -e "\nInvalid input directory, $input_dir.\n"
        return
    fi
    if [ ! -f $geogrid_file ]; then
        echo -e "\nInvalid geogrid file, $geogrid_file.\n"
        return
    fi

    $CONVERT_W2WH $input_dir $geogrid_file ${RUN_DIR_BASE}_${run_id}
    return
}



# (8) wh_hydro_nlist  <run_id> [<0 ... 5>]            # create hydro.namelist w routing opts
function wh_hydro_nlist() {
    if   [[ "$#" -lt 1 || "$#" -gt 7 ]]; then 
        echo -e "\n\tUSAGE: wh_hydro_nml <run_id> [<0 ... 5>]\n"
        return
    fi
    local run_id="$1"
    shift
    local routing_opts="$*"
    local run_dir_path=${RUN_DIR_BASE}_${run_id}

    if [ ! -d $run_dir_path ]; then
        echo -e "\n\tRun directory does not exist: $run_dir_path.\n"
        return
    fi

    cp $WH_R2_REPO/namelists/hydro.namelist.template $run_dir_path/hydro.namelist
    $WH_R2_REPO/run_scripts/create_hydro_namelist.sh $run_dir_path/hydro.namelist $routing_opts
    return
}


# (9) wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours>   # create namelist.hrldas w simulation period
function wh_hrldas_nlist() {
    if [ $# -ne 6 ]; then
        echo -e "\n\tUSAGE: wh_hrldas_nml <run_id> <yyyy> <mm> <dd> <hh> <sim_hours>\n"
        return
    fi
    local run_id="$1"
    shift
    local hrldas_opts="$*"
    local run_dir_path=${RUN_DIR_BASE}_${run_id}
    if [ ! -d $run_dir_path ]; then
        echo -e "\nInvalid run directory, $run_dir_path, for <run_id> = $run_id.\n"
        return
    fi

    cp $WH_R2_REPO/namelists/namelist.hrldas.template $run_dir_path/namelist.hrldas
    $WH_R2_REPO/run_scripts/create_hrldas_namelist.sh $run_dir_path/namelist.hrldas $hrldas_opts
    return
}



# (10) wh_job  <run_id> <queue_name> <minutes> <cores>      # create batch job submit script
function wh_job() {
    if [ $# -ne 4 ]; then
        echo -e "\n\tUSAGE: wh_job <run_id> <queue_name> <minutes> <cores>\n"
        return
    fi
    local run_id="$1"
    local queue_name="$2"
    local mins=${3#0}
    local num_cores="$4"

    local mins_0pad=""
    if [ $mins -lt 10 ]; then
        mins_0pad="0$mins"
    else
        mins_0pad="$mins"
    fi

    local run_dir_path=${RUN_DIR_BASE}_${run_id}
    if [ ! -d $run_dir_path ]; then
        echo -e "\nInvalid run directory, $run_dir_path, for <run_id> = $run_id.\n"
        return
    fi

    cp $WH_R2_REPO/supplements/submit.sh.template $run_dir_path/submit
    run_dir_sed_safe=${run_dir_path////'\/'}

    sed -i'' "s/queuename/$queue_name/g"          $run_dir_path/submit
    sed -i'' "s/queuetime/00:${mins_0pad}:00/g"   $run_dir_path/submit
    sed -i'' "s/numcores/$num_cores/g"            $run_dir_path/submit
    sed -i'' "s/jobname/$run_id/g"                $run_dir_path/submit
    sed -i'' "s/rundir/$run_dir_sed_safe/g"       $run_dir_path/submit

    echo -e "\n\tJob ID:        $run_id."
    echo -e   "\tRun directory: $run_dir_path.\n"
    echo -e "\tsbatch $run_dir_path/submit\n\n"
    return
}



# (11) wh_list                   # list wrf-hydro defined functions
function wh_list() {
    echo -e '\n'
    echo -e '                   WRF_HYDRO-R2 FUNCTIONS '
    echo -e '                   ====================== '
    echo -e '\n'
    echo -e '  wh_dev          <queue_name> <minutes>                      # slurm request interactive compute session\n'
    echo -e '  wh_sub_mod                                                  # init/update submodules'
    echo -e '  wh_build_nwm                                                # compile wrf-hydro/nwm executable'
    echo -e '  wh_clean_nwm                                                # clean out nwm build\n'
    echo -e '  wh_run_dir      <run_id>                                    # create run directory, copy exe + aux files'
    echo -e '  wh_domain       <run_id> <domain_id>                        # copy cutout to DOMAIN/'
    echo -e '  wh_forcing      <run_id> <input_dir> <geogrid_file>         # subset + regrid forcing files to FORCING/'
    echo -e '  wh_hydro_nlist  <run_id> <routing_opts>                     # create hydro.namelist w routing options'
    echo -e '  wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours>  # create namelist.hrldas w simulation period'
    echo -e '  wh_job          <run_id> <queue_name> <minutes> <cores>     # create slurm batch submit script\n'
    echo -e '  wh_list                                                     # list wrf-hydro defined functions'
    echo -e '  wh_list_domain                                              # list wrf-hydro cutout domains'
    echo -e '  wh_list_routing                                             # list routing/physics options'
    echo -e '\n'
    return
}



# (12) wh_list_domain                           # list wrf-hydro cutout domains
function wh_list_domain() {
    echo -e "\n\tNUM:   Gauge ID  -  Description"
    echo -e "\t----------------------------------------------------"
    echo -e "\t  1:   $CUTOUT1  -  $CUTOUT1_DESC"
    echo -e "\t  2:   $CUTOUT2  -  $CUTOUT2_DESC"
    echo -e "\t  3:   $CUTOUT3  -  $CUTOUT3_DESC"
    echo -e "\t  4:   $CUTOUT4  -  $CUTOUT4_DESC"
    echo -e "\t  5:   $CUTOUT5  -  $CUTOUT5_DESC"
    echo -e "\t  6:   $CUTOUT6  -  $CUTOUT6_DESC"
    echo -e "\t  7:   $CUTOUT7  -  $CUTOUT7_DESC"
    echo -e "\t  8:   $CUTOUT8  -  $CUTOUT8_DESC"
    echo -e "\n"
    return
}



# (13) wh_list_routing                        # list routing/physics options
function wh_list_routing() {
    echo -e "\n\tNUM:   Routing Opt. -  Description"
    echo -e "\t----------------------------------------------------"
    echo -e "\t  0:   LSM          -  NoahMP Land Surface Model [selected by default]"
    echo -e "\t  1:   SUB          -  Subsurface Flow Routing"
    echo -e "\t  2:   OVR          -  Overland Flow Routing"
    echo -e "\t  3:   CHL          -  Channel Routing"
    echo -e "\t  4:   RES          -  Lakes/Reservoir Routing"
    echo -e "\t  5:   GWB          -  Groundwater/baseflow Routing"
    echo -e "\n"
    return
}

