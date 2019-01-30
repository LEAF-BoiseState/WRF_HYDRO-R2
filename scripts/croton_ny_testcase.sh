#!/bin/bash

# *****************************************************************************
# FILE:     croton_ny_testcase.sh
# AUTHOR:   Matt Masarik      (MM) 
# VERSION:  0     2019-01-29   MM    Base version
#
# PURPOSE:  Retrieves the Croton_NY testcase and runs it.  The wrf_hydro.exe
#           must already be built.
#
# USAGE:    ./croton_ny_testcase.sh
# *****************************************************************************

# USER PARAMETERS - CHANGE ME!
QUEUE_TIME='00:10:00'           # runtime:   hh:mm:ss  [00:10:00  default]
NUM_CORES=4                     # mpi tasks: 1-28      [4         default]
JOB_NAME='whcroton'             # jobname:   8 chars
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
sed -i "s/queuetime/$QUEUE_TIME/g"          submit
sed -i "s/numcores/$NUM_CORES/g"            submit
sed -i "s/jobname/$JOB_NAME/g"              submit
sed -i "s/rundir/$nwm_run_dir_sed_safe/g"    submit

# submit batch job
sbatch submit

exit
