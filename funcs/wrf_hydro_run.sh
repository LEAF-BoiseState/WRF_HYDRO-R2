#!/bin/bash

#
# wrf_hydro_run_funcs.sh,  jun 24, 2019  Matt Masarik
#
# PURPOSE: set of functions to simply build and run related tasks.
# USAGE:   source wrf_hydro_run_funcs.sh
#
# FUNCTION DEFS:
#   (1)  wh_dev      <queue_name> <sim_time>                    # slurm request interactive compute session
#
#   (2)  wh_sub_mod                                             # init/update submodules
#   (3)  wh_build                                               # compile the wrf-hydro/nwm executable
#
#   (4)  wh_run_dir  <run_id>                                   # create wrf-hydro run (parent) directory
#   (5)  wh_run_dom  <run_id> <domain_id>                       # create DOMAIN from cutout in run dir
#   (6)  wh_run_rto  <run_id> <routing_opt>                     # copy exe + associated files to run dir
#   (7)  wh_run_frc  <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING
# ii  (8)  wh_run_job  <run_id> <yyyy> <mm> <dd> <hh> <sim_days>  # set namelist sim time and submit job
#
#   (9)  wh_list                                                # list wrf-hydro defined functions
#  (10)  wh_list_dom                                            # list wrf-hydro cutout domains
#  (11)  wh_list_rto                                            # list routing/physics options
#  (12) wh_clean_nwm                                           # clean NWM repo build 
#


# USER PARAMETERS
RUN_DIR_BASE="/scratch/${USER}/WH_SIM"



# ----------------------------- FIXED PARAMETERS ------------------------------
WH_R2_FUNCS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"    # path of script
WH_R2_REPO=${WH_R2_FUNCS_DIR%/*}                                                       # WH_R2 repo base dir
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

# routing options
NUM_ROUTING_OPTS=7
ROUTING1=1
ROUTING1_STR='lsm'
ROUTING1_DESC='NoahMP LSM'

ROUTING2=2
ROUTING2_STR='lsm_sub'
ROUTING2_DESC='NoahMP LSM + Subsurface routing'

ROUTING3=3
ROUTING3_STR='lsm_ovr'
ROUTING3_DESC='NoahMP LSM + Overland surface flow routing'

ROUTING4=4
ROUTING4_STR='lsm_chl'
ROUTING4_DESC='NoahMP LSM + Channel routing'

ROUTING5=5
ROUTING5_STR='lsm_res'
ROUTING5_DESC='NoahMP LSM + Lake/reservoir routing'

ROUTING6=6
ROUTING6_STR='lsm_gwb'
ROUTING6_DESC='NoahMP LSM + Groundwater/baseflow model'

ROUTING7=7
ROUTING7_STR='lsm_ovr_chl'
ROUTING7_DESC='NoahMP LSM + Overland surface flow routing + Channel routing'




# (1) wh_dev:  request WRF-Hydro dev session 
#       input: queue name, requested simulation time
function wh_dev() {
    local session_id='WRFHYDEV'
    local let MAXMINS=60

    if [ $# -ne 2 ]; then
        echo -e "\n\tUSAGE: wh_dev <queue_name> <simulation_minutes>\n"
        return
    elif [[ $2 -le 0 || $2 -gt $MAXMINS ]]; then
        echo -e "\n\tUSAGE: wh_dev <queue_name> <simulation_minutes>"
        echo -e   "\t\twhere, 0  <  <simulation_minutes>  <=  60.\n"
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


# (2) wh_sub_mod
function wh_sub_mod() {
    local start_dir=$(pwd)
    cd $WH_R2_REPO
    git submodule init
    git submodule update
    cd $start_dir
    return
}


# (3) wh_build                                               # compile the wrf-hydro/nwm executable
function wh_build() {
    $WH_R2_REPO/build/build_nwm_r2.sh
    return
}


# (4) wh_run_dir: create WRF-Hydro run directory
#       input:    run ID 
function wh_run_dir() {
    if [ $# -ne 1 ]; then
        echo -e "\n\tUSAGE: wh_run_dir <run_id>\n"
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
    return
}

# (5) wh_run_dom: 
function wh_run_dom() {
    if   [ $# -ne 2 ]; then 
        echo -e "\n\tUSAGE: wh_run_dom <run_id> <domain_id>\n"
        return
    elif [[ $2 -lt 1 || $2 -gt $NUM_CUTOUTS ]]; then
        echo -e "\n\tUSAGE: wh_run_dom <run_id> <domain_id>"
        echo -e   "\t\twhere, 1 <= <dom_id> <= $NUM_CUTOUTS.\n"
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



# (6) wh_run_rto:
function wh_run_rto() {
    if   [ $# -ne 2 ]; then 
        echo -e "\n\tUSAGE: wh_run_rto <run_id> <routing_opt>\n"
        return
###    elif [[ $2 -lt 1 || $2 -gt $NUM_ROUTING_OPTS ]]; then  
    elif [[ $2 -lt $NUM_ROUTING_OPTS || $2 -gt $NUM_ROUTING_OPTS ]]; then
        echo -e "\n\tUSAGE: wh_run_rto <run_id> <routing_opt>"
        echo -e   "\t\twhere, 1 <= <routing_opt> <= $NUM_ROUTING_OPTS.\n"
        return
    fi
    local run_id="$1"
    local routing_opt=$2
    local run_dir_path=${RUN_DIR_BASE}_${run_id}
    if [ ! -d $run_dir_path ]; then
        echo -e "\n\tRun directory does not exist: $run_dir_path.\n"
        return
    fi

    # copy exe and associated files to parent
    cp    $NWM_BUILD_RUN_DIR/* $run_dir_path
    mv    $run_dir_path/hydro.namelist  $run_dir_path/hydro.namelist.build
    mv    $run_dir_path/namelist.hrldas $run_dir_path/namelist.hrldas.build

    # copy routing specific namelists to parent
    if   [ $routing_opt -eq $ROUTING1 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING1_STR - $ROUTING1_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING1_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING1_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING2 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING2_STR - $ROUTING2_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING2_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING2_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING3 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING3_STR - $ROUTING3_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING3_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING3_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING4 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING4_STR - $ROUTING4_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING4_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING4_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING5 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING5_STR - $ROUTING5_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING5_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING5_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING6 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING6_STR - $ROUTING6_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING6_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING6_STR $run_dir_path/namelist.hrldas
    elif [ $routing_opt -eq $ROUTING7 ]; then
	echo  -e "\n\t$routing_opt:  $ROUTING7_STR - $ROUTING7_DESC"
	cp       $WH_R2_REPO/namelists/hydro.namelist.$ROUTING7_STR $run_dir_path/hydro.namelist
	cp       $WH_R2_REPO/namelists/namelist.hrldas.$ROUTING7_STR $run_dir_path/namelist.hrldas
    else
        echo  -e "\nInvalid routing option, routing_opt == $routing_opt.\n"
        return
    fi
    return
}


# (7)  wh_run_frc <run_id> <input_dir> <geogrid_file>
function wh_run_frc() {
    if [ $# -ne 3 ]; then
        echo -e "\n\tUSAGE: wh_run_frc <run_id> <input_dir> <geogrid_file>\n"
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

# (8)  wh_run_job  <run_id> <yyyy> <mm> <dd> <hh> <sim_days>  # set namelist sim time and submit job
function wh_run_job() {
    local QUEUE_NAME="leaf"
    local QUEUE_TIME="00:10:00"
    local NUM_CORES=1
    if [ $# -ne 6 ]; then
        echo -e "\n\tUSAGE: wh_run_job <run_id> <yyyy> <mm> <dd> <hh> <sim_days>\n"
        return
    fi
    local run_id="$1"
    local year="$2"
    local mn="$3"
    local dy="$4"
    local hr="$5"
    local sim_days="$6"
    local run_dir_path=${RUN_DIR_BASE}_${run_id}
    if [ ! -d $run_dir_path ]; then
        echo -e "\nInvalid run directory, $run_dir_path, for <run_id> = $run_id.\n"
        return
    fi
    if [ ! -f $run_dir_path/hydro.namelist ]; then
        echo -e "\nNo valid hydro.namelist, $run_dir_path/hydro.namelist, found.\n"
        return
    fi
    if [ ! -f $run_dir_path/namelist.hrldas ]; then
        echo -e "\nNo valid namelist.hrldas, $run_dir_path/namelist.hrldas, found.\n"
        return
    fi

    sed -i "s/startyear/$year/g"   $run_dir_path/namelist.hrldas
    sed -i "s/startmonth/$mn/g"    $run_dir_path/namelist.hrldas
    sed -i "s/startday/$dy/g"      $run_dir_path/namelist.hrldas
    sed -i "s/starthour/$hr/g"     $run_dir_path/namelist.hrldas
    sed -i "s/simdays/$sim_days/g" $run_dir_path/namelist.hrldas

    cp -v $WH_R2_REPO/run_scripts/submit.sh.template $run_dir_path
    mv -v $run_dir_path/submit.sh.template $run_dir_path/submit
    run_dir_sed_safe=${run_dir_path////'\/'}

    sed -i "s/queuename/$QUEUE_NAME/g"       submit
    sed -i "s/queuetime/$QUEUE_TIME/g"       submit
    sed -i "s/numcores/$NUM_CORES/g"         submit
    sed -i "s/jobname/$run_id/g"             submit
    sed -i "s/rundir/$run_dir_sed_safe/g"    submit

    echo -e "\n\tJob ID, $run_id, ready for submission."
    echo -e "\tRun directory: $run_dir_path.\n"
    echo -e "\tsbatch $run_dir_path/submit\n\n"
    return
}



# (9)  wh_list                                                # list wrf-hydro defined functions
function wh_list() {
    echo -e '\n'
    echo -e '                   WRF_HYDRO-R2 FUNCTIONS '
    echo -e '                   ====================== '
    echo -e '\n'
    echo -e '  wh_dev      <queue_name> <sim_time>                    # slurm request interactive compute session\n'
    echo -e '  wh_sub_mod                                             # init/update submodules'
    echo -e '  wh_build                                               # compile the wrf-hydro/nwm executable\n'
    echo -e '  wh_run_dir  <run_id>                                   # create wrf-hydro run (parent) directory'
    echo -e '  wh_run_dom  <run_id> <domain_id>                       # create DOMAIN from cutout in run dir'
    echo -e '  wh_run_rto  <run_id> <routing_opt>                     # copy exe + associated files to run dir'
    echo -e '  wh_run_frc  <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING'
    echo -e '  wh_run_job  <run_id> <yyyy> <mm> <dd> <hh> <sim_days>  # set namelist sim time and submit job\n'
    echo -e '  wh_list                                                # list wrf-hydro defined functions'
    echo -e '  wh_list_dom                                            # list wrf-hydro cutout domains'
    echo -e '  wh_list_rto                                            # list routing/physics options\n'
    echo -e '  wh_clean_nwm                                           # clean NWM repo build'
    echo -e '\n'
    return
}


# (10)  wh_list_dom                                            # list wrf-hydro cutout domains
function wh_list_dom() {
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



#  (11)  wh_list_rto                                            # list routing/physics options
function wh_list_rto() {
    echo -e "\n\tNUM:   Routing option  -  Description"
    echo -e "\t----------------------------------------------------"
    echo -e "\t  1:     $ROUTING1_STR\t\t  -  $ROUTING1_DESC"
    echo -e "\t  2:     $ROUTING2_STR\t  -  $ROUTING2_DESC"
    echo -e "\t  3:     $ROUTING3_STR\t  -  $ROUTING3_DESC"
    echo -e "\t  4:     $ROUTING4_STR\t  -  $ROUTING4_DESC"
    echo -e "\t  5:     $ROUTING5_STR\t  -  $ROUTING5_DESC"
    echo -e "\t  6:     $ROUTING6_STR\t  -  $ROUTING6_DESC"
    echo -e "\t  7:     $ROUTING7_STR\t  -  $ROUTING7_DESC"
    echo -e "\n"
    return
}


#  (12)  wh_clean_nwm
function wh_clean_nwm() {
    if [ -d $NWM_BUILD_DIR/Run         ]; then rm -vrf $NWM_BUILD_DIR/Run;        fi
    if [ -f $NWM_BUILD_DIR/setEnvar.sh ]; then rm -vf $NWM_BUILD_DIR/setEnvar.sh; fi
    if [ -f $NWM_BUILD_DIR/macros.orig ]; then rm -vf $NWM_BUILD_DIR/macros.orig; fi
    return
}

