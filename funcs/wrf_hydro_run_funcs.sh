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
#

# global parameters
RUN_DIR_BASE="/scratch/${USER}/WH_SIM"



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


