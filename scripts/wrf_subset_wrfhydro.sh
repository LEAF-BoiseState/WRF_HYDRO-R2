#!/bin/bash

# ******************************************************************************
# FILE:    wrf_subset_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-02-21   MM Initial version
#
# PURPOSE: Create hourly files with surface variables needed by WRF-Hydro, by
#          extracting variables from WRF wrfout's and putting in new netCDF 
#          file. If rain buckets are used, combine I_RAINNC (bucket) with 
#          RAINNC by setting RAINNC_BUCKET_FLAG to true in Declarations, below.
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
# Times,XLAT,XLONG,HGT,PSFC,U10,V10,T2,Q2,RAINNC,I_RAINNC,SWDOWN,GLW
# ******************************************************************************


# ------------------------------------------------------------------------------
# (1) Declarations
# ------------------------------------------------------------------------------
RAINNC_BUCKET_FLAG=true     # true  = combine RAINNC and I_RAINNC
                            # false = RAINNC and I_RAINNC left alone

# ------------------------------------------------------------------------------
# (2) Module loads
# ------------------------------------------------------------------------------
# no module loads
echo -e "\n\n"


# ------------------------------------------------------------------------------
# (3) Function Defs
# ------------------------------------------------------------------------------
# (3.0) subset - create a file of listed subset variables
# -------------------------------------------------------
function subset() {
  #
  # PURPOSE: Extract variables listed in <variable_list_file> from <input_file>
  #          and put them in <output_file>.  If <bucket_flag> = true, and the
  #          variables RAINNC and I_RAINNC are both in <variable_list_file>,
  #          then RAINNC and I_RAINNC are combined to make a new variable RAINNC
  #          (RAINNC = RAINNC + I_RAINNC * 100.0).
  #
  # USAGE:   subset <variable_list_file> <input_file> <output_file> <bucket_flag>
  #

  # check for correct number of args, put in named variables
  if [ ! $# -eq 4 ]; then
    local args="<variable_list_file> <input_file> <output_file> <bucket_flag>"
    echo -e "\nUsage: subset $args\n"
    exit 1
  fi
  local var_list_file=$1
  local in_file=$2
  local out_file=$3
  local bucket_flag=$4


  # get list of variables from variable list file
  local var_list=$(cat $var_list_file)

  # display file and variable info
  echo -e "Input file:         $in_file"
  echo -e "Output file:        $out_file"
  echo -e "Variables:          $var_list"
  echo -e "Rain bucket flag:   $bucket_flag\n"
  sleep 4


  # (3.3.1) RAINNC / I_RAINNC block (1 of 2): modify subset variable list
  # ---------------------------------------------------------------------
  # check RAINNC and I_RAINNC are variables to be extracted
  local rainnc_flag=$(echo $var_list | grep -i 'RAINNC' | wc -l)
  local i_rainnc_flag=$(echo $var_list | grep -i 'I_RAINNC' | wc -l)

  # test that both were found above, and that conversion from buckets is desired
  if [ "$rainnc_flag" -ne 0 ] && [ "$i_rainnc_flag" -ne 0 ] && \
     [ "$bucket_flag" = "true" ]; then
  
    # remove 'RAINNC,' and 'I_RAINNC,' from variable contain extraction variables
    # note: include the comma's as shown..
    var_list=${var_list/'RAINNC,'/''}
    var_list=${var_list/'I_RAINNC,'/''}
  fi


  # (3.3.2) Extract subset variables
  # --------------------------------
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


  # let user know variable extraction / file creation are complete
  echo -e "Finished creating file: $out_file"
  sleep 2

  return
}


# ------------------------------------------------------------------------------
# (3) User input
# ------------------------------------------------------------------------------
# check for correct number of arguments, put args in named variables
if [ ! $# -eq 2 ]; then
  echo -e "\nUsage: $0 <wrfout_file> <output_dir>\n"
  exit
fi
wrfout_file=$1
output_dir=$2


# ------------------------------------------------------------------------------
# (4) Main
# ------------------------------------------------------------------------------

# check wrfout file exists
if [ ! -f $wrfout_file ]; then
  echo -e "\nThe wrfout file, $wrfout_file, was not found. Exiting.\n\n"
  exit 2
fi

# check output directory exists
if [ ! -d $output_dir ]; then
  echo -e "\nThe output directory, $output_dir, was not found. Exiting.\n\n"
  exit 2
fi


# display wrfout directory and variable info
echo -e   "Output Directory:  $output_dir"
sleep 4

# ##############################################################
  # get output file name
  var_output_file=${wrfout_input_file//':'/'_'}     # replace all ':' with '_'
  var_output_file=${var_output_file%.nc}_${subset_suffix}.nc

  # call to subset function
  echo -e "\nCalling function subset..."
  sleep 2
  subset $var_list_file $wrfout_input_file $var_output_file $RAINNC_BUCKET_FLAG
  echo -e "\nCompleted function subset.\n"
  sleep 2

  # move output file to output directory
  echo -e "Moving output file, $var_output_file, to directory: $output_dir..."
  sleep 2
  mv -v $var_output_file $output_dir
# ##############################################################

exit
