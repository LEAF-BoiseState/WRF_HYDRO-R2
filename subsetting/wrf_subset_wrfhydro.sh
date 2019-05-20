#!/bin/bash

# ******************************************************************************
# FILE:    wrf_subset_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-02-21   MM Initial version
#          1  2019-05-20   MM Added: RAINC, LAI, VEGFRA
#
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
#           NEEDED      WRF        DESC                            UNITS
#           ======      ====       ====                            =====
#           SWDOWN      SWDOWN     short-wave rad down             W/m^2
#           LWDOWN      GLW        long-wave rad down              W/m^2
#           Q2D         Q2         specific humidity               kg/kg
#           T2D         T2         air temperature                 K
#           PSFC        PSFC       surface pressure                Pa
#           U2D         U10        u-wind (zonal) 10-m             m/s
#           V2D         V10        v-wind (merid.) 10-m            m/s
#           RAINRATE    RAINNC     precipitation rate (non-conv)   mm/s
#                       I_RAINNC   precip bucket, 100.0            mm
#                       RAINC      precipitation rate (conv)       mm/s
#                       VEGFRA     vegetation fraction             NA
#                       LAI        leaf area index                 m^2/m^2
#
#                       HGT        terrain height                  m
#                       XLAT       latitude wrf grid               degree_north
#                       XLONG      longitude wrf grid              degree_east
#                       Times      time steps                      date/time
#
# 
# NOTE:   Formula for rain buckets, bucket value is 100.0 mm.
#          * RAINNC = RAINNC + I_RAINNC * 100.0
#
# ******************************************************************************

# Parameters
# ----------
RAINNC_BUCKET_FLAG="true"   # true  = combine RAINNC and I_RAINNC
                            # false = RAINNC and I_RAINNC left alone
LSM_VARS="Times,XLAT,XLONG,HGT,PSFC,U10,V10,T2,Q2,RAINC,RAINNC,I_RAINNC,SWDOWN,GLW,VEGFRA,LAI"
ENV_SCRIPT=/home/$USER/LEAF/WRF_HYDRO-R2/subsetting/env_subset_r2.sh


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
var_list=""
if [ $RAINNC_BUCKET_FLAG = "true" ]; then
    var_list=$LSM_VARS
else
    var_list=${LSM_VARS/'I_RAINNC,'/''}
fi


# Main
# ----
# Name for output files
tmp_outfile=${wrfout_file%*_00:00:00}_tmp
day_outfile=${wrfout_file%*_00:00:00}


# Extract listed variables
echo -e "ncks -a -v $var_list $wrfout_file $tmp_outfile"
sleep 1
ncks -a -v $var_list $wrfout_file $output_dir/$tmp_outfile
status="$?"
if [ $status -ne 0 ]; then
    exit $status
fi

# Rain buckets
if [ $RAINNC_BUCKET_FLAG = "true" ]; then

    # Combine RAINNC + I_RAINNC
    rainnc_equation="RAINNC = RAINNC + I_RAINNC * 100.0"
    echo "ncap2 -A -v -s \"$rainnc_equation\" $tmp_outfile $tmp_outfile"
    sleep 1
    ncap2 -A -v -s "$rainnc_equation" $output_dir/$tmp_outfile $output_dir/$tmp_outfile
    status="$?"
    if [ $status -ne 0 ]; then
	exit $status
    fi

    # Remove I_RAINNC
    echo -e "ncks -x -v I_RAINNC $tmp_outfile $day_outfile"
    sleep 1
    ncks -x -v I_RAINNC $output_dir/$tmp_outfile $output_dir/$day_outfile
    status="$?"
    if [ $status -ne 0 ]; then
	exit $status
    fi
fi


# De-aggregate from day -> to -> hourly files
time_pat='Time = UNLIMITED'
let num_steps=$(ncdump -h $wrfout_file | grep "$time_pat" | grep -oP '[0-9]+')
let t
for (( t=0; t<=$num_steps-1; t++ ))
do
    # 0-pad hour
    t_pad="$t"
    if [ $t -lt 10 ]; then 
        t_pad="0$t"
    fi

    # Extract each hour
    hour_outfile=${day_outfile}_${t_pad}:00:00
    ncks -d Time,$t,$t $output_dir/$day_outfile $output_dir/$hour_outfile
done


# Clean up
rm -f $output_dir/$tmp_outfile
rm -f $output_dir/$day_outfile



exit

