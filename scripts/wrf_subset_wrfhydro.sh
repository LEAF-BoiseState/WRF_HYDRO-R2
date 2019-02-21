#!/bin/bash

# ******************************************************************************
# FILE:    wrf_subset_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-02-21   MM Initial version
#
# PURPOSE: Create hourly files with surface variables needed by WRF-Hydro, by
#          extracting variables from WRF wrfout's and putting in new netCDF 
#          file. If rain buckets are used, combine I_RAINNC (bucket) with 
#          RAINNC by setting RAINNC_BUCKET_FLAG to true below.
#
#
# USAGE:   ./wrf_subset_wrfhydro.sh <wrfout_file> <output_dir>
#
#          where,
#                 <wrfout_file>   = wrfout file name
#                 <output_dir>    = directory for output files
#
# VARS:    Variables needed by Noah-MP LSM
#           NEEDED      WRF      DESC                    UNITS
#           ======      ====     ====                    =====
#           SWDOWN      SWDOWN   short-wave rad down     W/m^2
#           LWDOWN      GLW      long-wave rad down      W/m^2
#           Q2D         Q2       specific humidity       kg/kg
#           T2D         T2       air temperature         K
#           PSFC        PSFC     surface pressure        Pa
#           U2D         U10      u-wind (zonal) 10-m     m/s
#           V2D         V10      v-wind (merid.) 10-m    m/s
#           RAINRATE    RAINNC   precipitation rate      mm/s
#
#                       HGT      terrain height          m
#                       XLAT     latitude wrf grid
#                       XLONG    longitude wrf grid
#                       Times    time steps
#
# 
# NOTE:
#          * Rain buckets:  RAINNC = RAINNC + I_RAINNC * 100.0
#
#
#          * Times,XLAT,XLONG,HGT,PSFC,U10,V10,T2,Q2,RAINNC,I_RAINNC,SWDOWN,GLW
# ******************************************************************************

# Parameters
# ----------
RAINNC_BUCKET_FLAG=true     # true  = combine RAINNC and I_RAINNC
                            # false = RAINNC and I_RAINNC left alone
LSM_VARS="Times,XLAT,XLONG,HGT,PSFC,U10,V10,T2,Q2,RAINNC,I_RAINNC,SWDOWN,GLW"
ENV_SCRIPT=/home/$USER/LEAF/WRF_HYDRO-R2/scripts/env_nwm_r2.sh


# Environment
# -----------
if [ ! -f $ENV_SCRIPT ]; then
    echo -e "\nNo environment script found, $ENV_SCRIPT. Exiting.\n\n"
    exit 1
fi
source $ENV_SCRIPT


# User input
# ----------
if [ ! $# -eq 2 ]; then
  echo -e "\nUsage: $0 <wrfout_file> <output_dir>\n"
  exit 1
fi
wrfout_file=$1
output_dir=$2


# Main
# ----
# check wrfout file exists
if [ ! -f $wrfout_file ]; then
  echo -e "\nThe wrfout file, $wrfout_file, was not found. Exiting.\n\n"
  exit 1
fi

# check output directory exists
if [ ! -d $output_dir ]; then
  echo -e "\nThe output directory, $output_dir, was not found. Exiting.\n\n"
  exit 1
fi

# check rain bucket flag
if [ $RAINNC_BUCKET_FLAG != "true" ]; then
    var_list=${LSM_VARS/'I_RAINNC,'/''}
fi


####
####


# call ncks to extract listed variables (-a = do not alphabetize fields)
echo -e "ncks -a -v $var_list $in_file $out_file"
sleep 1
ncks -a -v $var_list $in_file $out_file

# check exit status of ncks
check_status "ncks (subset) $in_file $out_file" "$?"
echo -e "\n"
sleep 1


# (3.3.3) RAINNC / I_RAINNC code block (2 of 2): combine (I_)RAINNC, append 
# -------------------------------------------------------------------------
# combine output file and tmp (rainnc output) file
if [ "$rainnc_flag" -ne 0 ] && [ "$i_rainnc_flag" -ne 0 ] && \
   [ "$bucket_flag" = "true" ]; then

  # convert from bucket to final value and re-name result RAINNC
  # ncap2 option flags:
  #    -A = Append to output file
  #    -v = Only write user defined variable (in this case the new RAINNC)
  #    -s = Use an inline script (the arithmetic expression in double quotes)
  rainnc_equation="RAINNC = RAINNC + I_RAINNC * 100.0"
  echo "ncap2 -A -v -s \"$rainnc_equation\" $in_file $out_file"
  sleep 1
  ncap2 -A -v -s "$rainnc_equation" $in_file $out_file

  # check status of ncap2 operation
  check_status "ncap2 - RAINNC: $in_file $out_file" "$?"
  echo -e "\n"
  sleep 1
fi

# -----------------------------------------------------------------------------









exit
