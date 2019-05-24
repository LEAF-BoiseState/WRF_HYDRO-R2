#!/bin/bash

# ******************************************************************************
# FILE:    convert_wrf_to_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-05-24   MM Initial version
#
# PURPOSE: Orchestrating script for converting WRF output (wrfout files) to
#          the format needed for input to WRF-Hydro.  In particular, the
#          wrfout's are subset (in time and variables), as well as spatially
#          regridded to the WRF-Hydro grid.  Spatial weights are generated
#          for the regridding if a spatialweights file is not supplied as the
#          optional argument.
#          
#
# USAGE:   ./convert_wrf_to_wrfhydro.sh  <wrfout_input>  <geogrid_file>  \
#                                        <output_dir>   [<weight_file>]  
#                                               
#          where,
#
#              <wrfout_input>   =  [SRC] (WRF grid) filename OR directory
#              <geogrid_file>   =  [DST] (WRF-Hydro grid) geogrid filename
#              <output_dir>     =  directory for output files
#              [<weight_file>]  = *Optional: weights to convert WRF->WRF-Hydro
#
# ******************************************************************************



# -----------------------------------------------------------------------------
# (1) Parameters
# -----------------------------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SUBSET_SCRIPT=$DIR/wrf_subset_wrfhydro.sh
GEN_WEIGHT_SCRIPT=$DIR/wrf_gen_weights_wrfhydro.sh
REGRID_SCRIPT=$DIR/wrf_regrid_wrfhydro.sh
DST_PREFIX=geo_em



# -----------------------------------------------------------------------------
# (2) User input
# -----------------------------------------------------------------------------
wrfout_input=""
geogrid_file=""
output_dir=""
weight_file=""
WEIGHT_FLAG=""
if [ "$#" -eq 4 ]; then
    wrfout_input="$1"
    geogrid_file="$2"
    output_dir="$3"
    weight_file="$4"
    WEIGHT_FLAG=true
elif [ "$#" -eq 3 ]; then
    wrfout_input="$1"
    geogrid_file="$2"
    output_dir="$3"
    WEIGHT_FLAG=false
else
    args='<wrfout_input> <geogrid_file> <output_dir> [<weight_file>]'
    echo -e "\n\tUsage: $0 $args\n"
    exit 1
fi


# check valid set of input
# ------------------------
# i)   wrfout - dir or file? exists?
WRFOUT_DIR_FLAG=""
if   [ -d "$wrfout_input" ]; then
    WRFOUT_DIR_FLAG=true
elif [ -f "$wrfout_input" ]; then
    WRFOUT_DIR_FLAG=false
else
    echo -e "\nNo valid wrfout input, $wrfout_input."
    echo -e "Exiting.\n"
    exit 2
fi

# ii)  geogrid file - exisits?
geogrid_filename=$(basename $geogrid_file)
geo_prefix=${geogrid_filename%%.*}
if [[ ! -f "$geogrid_file" ]] || [[ "$geo_prefix" != "DST_PREFIX" ]]; then
    echo -e "\nNo valid geogrid file, $geogrid_file."
    echo -e "Exiting.\n"
    exit 2
fi

# iii) output dir - exisits?
if [ ! -d "$output_dir" ]; then
    echo -e "\nNo output directory, $output_dir, found."
    echo -e "Creating directory, $output_dir."
    mkdir -vp $output_dir
    if [ "$?" -ne 0 ]; then 
        echo -e "\nCannot create output directory, $output_dir."
        echo -e "Exiting.\n"
        exit 2
    fi
fi

# *iv) weights file - exitists?
if [[ "$WEIGHT_FLAG" == "true" ]] && [[ ! -f "$weight_file" ]]; then
    echo -e "\nInvalid spatial weight file given, $weight_file."
    echo -e "Exiting.\n"
    exit 2
fi


# Display user input
echo -e "\n\n\t**  USER INPUT  **"
echo -e     "\t=================="
echo -e     "\t1) wrfout input:  $wrfout_input"
echo -e     "\t2) geogrid file:  $geogrid_file"
echo -e     "\t3) output dir:    $output_dir"
if [ "$WEIGHT_FLAG" == "true" ]; then
    echo -e     "\t4) weight file:   $weight_file"
else
    echo -e     "\t4) weight file:   None input. Will be generated."
fi
echo -e "\n\n"



# -----------------------------------------------------------------------------
# (3) Main
# -----------------------------------------------------------------------------
start_dir=$(pwd)

# go to output dir
cd $output_dir



# (1) Subset
# ----------



# *(2) Generate Weights [optional]
# --------------------------------



# (3) Regrid
# ----------





cd $start_dir

exit
