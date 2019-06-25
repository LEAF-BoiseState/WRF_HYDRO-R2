#!/bin/bash

#
# wrf_hydro_run_funcs.sh,  jun 24, 2019  Matt Masarik
#
# PURPOSE: set of functions to simply build and run related tasks.
# USAGE:   source wrf_hydro_run_funcs.sh
#
# FUNCTION DEFS:
#   (1)    wh_dev      <queue_name> <sim_time>     # request wrf-hydro dev session
#   (2)    wh_run_dir  <run_id>                    # create wrf-hydro run (parent) directory
#   (3)    wh_run_exe  <run_id>
#   (4)    wh_run_dom  <run_id>
#

# global parameters
RUN_DIR_BASE="/scratch/${USER}/WH_SIM"
NWM_BUILD=wrf_hydro_nwm_public/trunk/NDHMS
CONVERT_W2WH=pre_process/convert_wrf_to_wrfhydro.sh

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



# (2) wh_run_dir: create WRF-Hydro run directory
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

# (4) wh_run_exe:
function wh_run_exe() {
    echo -e "IMPLEMENT ME:  wh_run_exe()"
    return
}


# (3) wh_run_dom: 
function wh_run_dom() {
    if   [ $# -ne 2 ]; then 
        echo -e "\n\tUSAGE: wh_run_dom <run_id> <domain_id>\n"
    elif [[ $2 -lt 1 || $2 -gt $NUM_CUTOUTS ]]; then
        echo -e "\n\tUSAGE: wh_run_dom <run_id> <domain_id>"
        echo -e   "\t\twhere, 1 <= <dom_id> <= $NUM_CUTOUTS.\n"
    fi
    local run_id="$1"
    local dom_id=$2
    local run_dir_path=${RUN_DIR_BASE}_$run_id
    if [ ! -d ${RUN_DIR_BASE}_$run_id ]; then
        echo -e "\n\tRun directory does not exist: $run_dir_path.\n"
        return
    if

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

