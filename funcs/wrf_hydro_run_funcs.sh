#!/bin/bash

#
# wrf_hydro_run_funcs.sh,  jun 24, 2019  Matt Masarik
#
# PURPOSE: set of functions to simply build and run related tasks.
# USAGE:   source wrf_hydro_run_funcs.sh
#


# wh_dev: WRF-Hydro dev session
function wh_dev() {
    local session_id='WRFHYDEV'               # can be changed
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




