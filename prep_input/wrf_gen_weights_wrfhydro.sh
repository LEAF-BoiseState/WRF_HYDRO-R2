#!/bin/bash

# ******************************************************************************
# FILE:    wrf_gen_weights_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-05-24   MM Initial version
#
# PURPOSE: Wrapper over ncl script, w2wh_esmf_generate_weights.ncl, which
#          generates weights to use to regrid output on the WRF grid to the
#          WRF-Hydro grid.
#         
#
# USAGE:   ./wrf_gen_weights_wrfhydro.sh <wrfout_file> <geogrid_file>    \
#                                        <output_dir>
#          where,
#
#              <wrfout_file>   = [SRC] wrfout (WRF grid) file name
#              <geogrid_file>  = [DST] geogrid (WRF-Hydro grid) file name
#              <output_dir>    = directory for output files
#
# ******************************************************************************



# -----------------------------------------------------------------------------
# (1) Parameters
# -----------------------------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NCL_SCRIPT_DIR=$DIR/"ncl_scripts"
GEN_WEIGHTS_SCRIPT=$NCL_SCRIPT_DIR/"w2wh_esmf_generate_weights.ncl"


# -----------------------------------------------------------------------------
# (2) User input
# -----------------------------------------------------------------------------
if [ "$#" -ne 3 ]; then
  args='<wrfout_file> <geogrid_file> <output_dir>'
  echo -e "\n\tUsage: $0 $args\n"
  exit 1
fi
wrfout_file="$1"
geogrid_file="$2"
output_dir="$3"

# Display user input
echo -e "\n\n\t**  USER INPUT  **"
echo -e     "\t=================="
echo -e     "\t1) wrfout file:   $wrfout_file"
echo -e     "\t2) geogrid file:  $geogrid_file"
echo -e     "\t3) output dir:    $output_dir\n\n"



# -----------------------------------------------------------------------------
# (3) Main
# -----------------------------------------------------------------------------
arg1=\'srcGridFile=\"$wrfout_file\"\'
arg2=\'dstGridFile=\"$geogrid_file\"\'
arg3=\'outputDir=\"$output_dir\"\'


# call ncl regrid routine
##echo eval ncl $arg1 $arg2 $arg3 $arg4 $REGRID_SCRIPT    # DEBUG
eval ncl $arg1 $arg2 $arg3 $GEN_WEIGHTS_SCRIPT


exit
