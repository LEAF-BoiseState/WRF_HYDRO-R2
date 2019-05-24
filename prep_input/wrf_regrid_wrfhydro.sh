#!/bin/bash

# ******************************************************************************
# FILE:    wrf_regrid_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-05-21   MM Initial version
#
# PURPOSE: Wrapper over ncl script, w2wh_esmf_regrid_w_weights.ncl, which
#          regrids WRF grid output to the WRF-Hydro grid using the weight file.
#
# USAGE:   ./wrf_regrid_wrfhydro.sh <wrfout_file> <geogrid_file>    \
#                                   <weight_file> <output_dir>
#          where,
#
#              <wrfout_file>   = [SRC] wrfout (WRF grid) file name
#              <geogrid_file>  = [DST] geogrid (WRF-Hydro grid) file name
#              <weight_file>   = file w weights to convert WRF->WRF-Hydro
#              <output_dir>    = directory for output files
#
# ******************************************************************************



# -----------------------------------------------------------------------------
# (1) Parameters
# -----------------------------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NCL_SCRIPT_DIR=$DIR/"ncl_scripts"
REGRID_SCRIPT=$NCL_SCRIPT_DIR/"w2wh_esmf_regrid_w_weights.ncl"


# -----------------------------------------------------------------------------
# (2) User input
# -----------------------------------------------------------------------------
if [ "$#" -ne 4 ]; then
  args='<wrfout_file> <geogrid_file> <weight_file> <output_dir>'
  echo -e "\n\tUsage: $0 $args\n"
  exit 1
fi
wrfout_file="$1"
geogrid_file="$2"
weight_file="$3"
output_dir="$4"

# Display user input
echo -e "\n\n\t**  USER INPUT  **"
echo -e     "\t=================="
echo -e     "\t1) wrfout file:   $wrfout_file"
echo -e     "\t2) geogrid file:  $geogrid_file"
echo -e     "\t3) weight file:   $weight_file"
echo -e     "\t4) output dir:    $output_dir\n\n"



# -----------------------------------------------------------------------------
# (3) Main
# -----------------------------------------------------------------------------
start_dir=$(pwd)

# go to output dir
cd $output_dir

# format args for call
arg1=\'srcGridFile=\"$wrfout_file\"\'
arg2=\'dstGridFile=\"$geogrid_file\"\'
arg3=\'wgtFileName=\"$weight_file\"\'
arg4=\'outputDir=\"$output_dir\"\'

# The call: ncl regrid routine
##echo eval ncl $arg1 $arg2 $arg3 $arg4 $REGRID_SCRIPT    # DEBUG
eval ncl $arg1 $arg2 $arg3 $arg4 $REGRID_SCRIPT

cd $start_dir

exit
