#!/bin/bash

# *****************************************************************************
# FILE:     build_nwm_r2.sh
# AUTHOR:   Matt Masarik      (MM) 
# VERSION:  0     2019-01-19   MM    Base version
#
# PURPOSE:  Builds the National Water Model (NWM) version of WRF-Hydro
#           on R2.  Assumes the NWM repo has been initialized/updated as
#           a submodule in the repo.
#
# USAGE:    ./build_nwm_r2.sh
# *****************************************************************************

# params
WH_CONFIG=3                                        # 3: Linux ifort compiler dmpar
SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"     # path of script
WH_R2_REPO=${SCRIPTS_DIR%/*}                       # WH_R2 repo base dir
NWM_REPO=$WH_R2_REPO/wrf_hydro_nwm_public          # NWM repo base dir
BUILD_DIR=$NWM_REPO/trunk/NDHMS
START_DIR=$(pwd)
LOG=WH_R2_noahMP_compile.log

# source shell env
echo -e "\nSourcing environment script, $SCRIPTS_DIR/$ENV_R2.."
source $SCRIPTS_DIR/env_nwm_r2.sh

# set WRF-Hydro options
echo -e "\nChange directory to build dir, $BUILD_DIR.."
cd $BUILD_DIR
cp -v $BUILD_DIR/template/setEnvar.sh .
sed -i 's/SPATIAL_SOIL=0/SPATIAL_SOIL=1/g'           setEnvar.sh  # SPATIAL_SOIL=1
sed -i 's/WRF_HYDRO_NUDGING=0/WRF_HYDRO_NUDGING=1/g' setEnvar.sh  # WRF_HYDRO_NUDGING=1 

# build
echo "$WH_CONFIG" | ./configure                    # send choice, call config
cp -v macros macros.orig                        
sed -i 's/mpif90/mpiifort -heap-arrays/g' macros   # edit macros for mpiifort
./compile_offline_NoahMP.sh setEnvar.sh 2>&1 | tee ./$LOG
callstatus="$?"
successmsg=$(grep 'Make was successful' $LOG)
if [[ $callstatus -ne 0 ]] || [[ ! $successmsg ]]; then
    echo -e "\n\n\t** BUILD UNSUCCESSFUL **"
    echo -e "\tReview log file: $BUILD_DIR/$LOG"
    echo -e "\tExiting."
    exit $callstatus
else
    echo -e "\n\n\t** BUILD SUCCESSFUL!!! **"
    echo -e     "\t-------------------------"
    echo -e "\tExecutable: $BUILD_DIR/Run/wrf_hydro_NoahMP.exe"
    echo -e "\tLog file:   $BUILD_DIR/$LOG"
fi


# # return home
# echo -e "\tReturning to initial directory, $START_DIR."
# cd $START_DIR

exit
