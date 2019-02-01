#!/bin/bash

# *****************************************************************************
# FILE:     croton_ny_setup.sh
# AUTHOR:   Matt Masarik      (MM) 
# VERSION:  0     2019-01-29   MM    Base version
#
# PURPOSE:  Retrieves the Croton_NY testcase and sets up a test run.  The 
#           wrf_hydro.exe must already be built.  
#           
# USAGE:    ./croton_ny_setup.sh
# *****************************************************************************

# USER PARAMETERS - CHANGE ME!
NUM_CORES=4                     # mpi tasks: 1-28      [4         default]
QUEUE_TIME='00:10:00'           # runtime:   hh:mm:ss  [00:10:00  default]
QUEUE_NAME=defq                 # queue:               [defq      default]
JOB_NAME='whcroton'             # jobname:   8 chars only
# --------------------------------------------------------------------------- #



#params
SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"     # path of script
WH_R2_REPO=${SCRIPTS_DIR%/*}                       # WH_R2 repo base dir
WH_BUILD_RUN_DIR=$WH_R2_REPO/wrf_hydro_nwm_public/trunk/NDHMS/Run
NWM_EXAMPLE_RUN_DIR=$WH_R2_REPO/croton_NY/NWM
CROTON_NY_GZ=https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.0.3/croton_NY_example_testcase.tar.gz

# retrieve testcase
wget $CROTON_NY_GZ
tar xvzf ${CROTON_NY_GZ##*/}
rm -f ${CROTON_NY_GZ##*/}
mv example_case croton_NY
cd $NWM_EXAMPLE_RUN_DIR

# copy tables and exe
cp -v $WH_BUILD_RUN_DIR/wrf_hydro_NoahMP.exe .
cp -v $WH_BUILD_RUN_DIR/*.TBL .
cp -r ../FORCING .

# create submit script
cp -v $SCRIPTS_DIR/env_nwm_r2.sh .
cp -v $SCRIPTS_DIR/submit.sh.template .
cp -v submit.sh.template submit
nwm_run_dir_sed_safe=${NWM_EXAMPLE_RUN_DIR////'\/'}
sed -i "s/queuename/$QUEUE_NAME/g"           submit
sed -i "s/queuetime/$QUEUE_TIME/g"           submit
sed -i "s/numcores/$NUM_CORES/g"             submit
sed -i "s/jobname/$JOB_NAME/g"               submit
sed -i "s/rundir/$nwm_run_dir_sed_safe/g"    submit

# display
echo -e "\n\n\t** Croton_NY Testcase setup finished. **"
echo -e     "\t----------------------------------------"
echo -e     "\tRun directory: $NWM_EXAMPLE_RUN_DIR"
echo -e     "\tRun command:   make run\n"


exit
