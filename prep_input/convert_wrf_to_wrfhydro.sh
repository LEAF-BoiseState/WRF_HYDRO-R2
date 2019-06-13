#!/bin/bash

# ******************************************************************************
# FILE:    convert_wrf_to_wrfhydro.sh
# AUTHOR:  Matt Masarik   (MM)
# VERSION: 0  2019-05-24   MM Initial version
#
# PURPOSE: Orchestrating script for converting WRF output (wrfout files) to
#          the format needed for input to WRF-Hydro.  In particular, the
#          wrfout's are subset (in time and field variables), as well as
#          spatially regridded (domain extent and resolution) to the WRF-Hydro
#          grid.  Spatial weights are generated for the regridding if a
#          spatialweights file is not supplied as the optional argument.
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
INPUT_PREP_ENV=$DIR/env_subset_r2.sh
DST_PREFIX=geo_em
SRC_PREFIX=wrfout
WEIGHTS_PREFIX=w2wh_spatialweight

# source environment script
if [ -f "$INPUT_PREP_ENV" ]; then
    source $INPUT_PREP_ENV
else
    echo -e "\nNo environment script, $INPUT_PREP_ENV, found."
    echo -e "Exiting.\n\n"
    exit 2
fi


# -----------------------------------------------------------------------------
# (2) User input
# -----------------------------------------------------------------------------
script_name=""
wrfout_input=""
geogrid_file=""
output_dir=""
weight_file=""
WEIGHT_FLAG=""
if [ "$#" -eq 4 ]; then
    script_name="$(basename $0)"
    wrfout_input="$1"
    geogrid_file="$2"
    output_dir="$3"
    weight_file="$4"
    WEIGHT_FLAG=true
elif [ "$#" -eq 3 ]; then
    script_name="$(basename $0)"
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
input_dir=""
WRFOUT_DIR_FLAG=""
if   [ -d "$wrfout_input" ]; then
    WRFOUT_DIR_FLAG=true
    input_dir=$wrfout_input
elif [ -f "$wrfout_input" ]; then
    WRFOUT_DIR_FLAG=false
    input_dir=$(dirname $wrfout_input)
else
    echo -e "\nNo valid wrfout input, $wrfout_input."
    echo -e "Exiting.\n"
    exit 2
fi

# ii)  geogrid file - exisits?
geogrid_filename=$(basename $geogrid_file)
geo_prefix=${geogrid_filename%%.*}
if [[ ! -f "$geogrid_file" ]] || [[ "$geo_prefix" != "$DST_PREFIX" ]]; then
    echo -e "\nNo valid geogrid file, $geogrid_file."
    echo -e "Exiting.\n"
    exit 2
fi

# iii) output dir - exisits? also, check if output dir == input dir
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
if [ "$input_dir" == "$output_dir" ]; then
    echo -e "\nInput directory and output directory must be distinct."
    echo -e "Input Dir == Output Dir == $input_dir."
    echo -e "Exiting.\n\n"
    exit 2
fi



# *iv) weights file - exitists?
if [[ "$WEIGHT_FLAG" == "true" ]] && [[ ! -f "$weight_file" ]]; then
    echo -e "\nInvalid spatial weight file given, $weight_file."
    echo -e "Exiting.\n"
    exit 2
fi



# Display user input
echo -e "\n\n**********************************"
echo -e     "SCRIPT: $script_name\n"
echo -e     "\t**  USER INPUT  **"
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

# FORCING dir in output dir
output_forcing_dir=$output_dir/FORCING
if [ -d $output_forcing_dir ]; then
    rm -rf $output_forcing_dir
fi
mkdir -p $output_forcing_dir
cd $output_forcing_dir


# get file list for dir input
num_wrfout_files=""
wrfout_file_list=""
if [ "$WRFOUT_DIR_FLAG" == "true" ]; then
    num_wrfout_files=$(ls -1 $input_dir/$SRC_PREFIX* 2> /dev/null | wc -l)
    if [ $num_wrfout_files -ge 1 ]; then
        wrfout_file_list="$(ls $input_dir/$SRC_PREFIX*)"
    else
        echo -e "\nNo valid input (wrfout) files found in, $input_dir."
        echo -e "Exiting.\n\n"
        exit 2
    fi
fi







# ** MAIN PROCESSING **
# =====================

# (1) Subset
# ----------
if [ "$WRFOUT_DIR_FLAG" == "false" ]; then
    $SUBSET_SCRIPT $wrfout_input $output_forcing_dir
    subset_status=$?
    if [ $subset_status -ne 0 ]; then
        echo -e "\nNon-zero exit status in subsetting, $wrfout_input."
        echo -e "Exiting.\n\n"
        exit $subset_status
    fi
else
    for wo in $wrfout_file_list
    do
        $SUBSET_SCRIPT $wo $output_forcing_dir        
        subset_status=$?
	if [ $subset_status -ne 0 ]; then
	    echo -e "\nNon-zero exit status in subsetting, $wo."
	    echo -e "Exiting.\n\n"
	    exit $subset_status
	fi
    done
fi



# *(2) Generate Weights [optional]
# --------------------------------
spatial_weights=""
if [ "$WEIGHT_FLAG" == "false" ]; then
    spatial_weights_file_count=$(ls -1 $output_forcing_dir/$WEIGHTS_PREFIX* 2> /dev/null | wc -l)
    if [ $spatial_weights_file_count -ge 1 ]; then 
        spatial_weights="$(ls $output_forcing_dir/$WEIGHTS_PREFIX* 2> /dev/null)"
        echo -e "\nNon-declared weight file(s) found in, $output_forcing_dir."
        echo -e "Removing $spatial_weights_file_count non-declared weight file(s), $spatial_weights..."
        rm -fv $spatial_weights
    fi
    first_wrfout=$(ls -1 $output_forcing_dir/$SRC_PREFIX* 2> /dev/null | head -1)

    # generate weight file call
    $GEN_WEIGHT_SCRIPT $first_wrfout $geogrid_file $output_forcing_dir
    gen_weight_status=$?
    if [ $gen_weight_status -ne 0 ]; then
        echo -e "\nNon-zero exit status in generating weights, src: $first_wrfout, dst: $geogrid_file."
        echo -e "Exiting.\n\n"
        exit $gen_weight_status
    fi
fi

# locate new or provide weight file
spatial_weights_count=$(ls -1 $output_forcing_dir/$WEIGHTS_PREFIX* 2> /dev/null | wc -l)
if [ $spatial_weights_count -gt 1 ]; then
    echo -e "\nMore than 1 spatial weight files found, $spatial_weights_count, only 1 allowed."
    echo -e "Exiting.\n\n"
    exit 2
elif [ $spatial_weights_count -eq 1 ]; then
    spatial_weights=$(ls $output_forcing_dir/$WEIGHTS_PREFIX* 2> /dev/null)
    weight_file=$spatial_weights
else
    echo -e "\nNo spatial weight file."
    echo -e "Exiting.\n\n"
    exit 2
fi



# (3) Regrid
# ----------
regrid_wrfout_file_list=""
num_regrid_wrfout_files=$(ls -1 $output_forcing_dir/$SRC_PREFIX*$NC_SUFFIX 2> /dev/null | wc -l)
if [ $num_regrid_wrfout_files -ge 1 ]; then
    regrid_wrfout_file_list="$(ls $output_forcing_dir/$SRC_PREFIX*$NC_SUFFIX)"
    echo -e "\nNumber of regridding input files found: $num_regrid_wrfout_files."
    echo -e "Files to be regridded:"
    ls -1 $output_forcing_dir/$SRC_PREFIX*$NC_SUFFIX
else
    echo -e "\nNo valid regridding input (wrfout\*.nc) files found in, $output_forcing_dir."
    echo -e "Exiting.\n\n"
    exit 2
fi

for rwo in $regrid_wrfout_file_list
do
    $REGRID_SCRIPT $rwo $geogrid_file $weight_file $output_forcing_dir
    regrid_status=$?
    if [ $regrid_status -ne 0 ]; then
        echo -e "\nNon-zero exit status in regridding, src: $rwo, dst: $geogrid_file, wgt: $weight_file."
        echo -e "Exiting.\n\n"
        exit $regrid_status
    fi
    mv $rwo ${rwo%.nc}
done


# display results
num_regridded_wrfout_files=$(ls -1 $output_forcing_dir/$SRC_PREFIX* 2> /dev/null | wc -l)
if [ $num_regridded_wrfout_files -ge 1 ];then
    echo -e "\nNumber of regridded wrfout files: $num_regridded_wrfout_files, in output directory, $output_forcing_dir."
    echo -e "Regridded wrfout files: "
    ls -1 $output_forcing_dir/$SRC_PREFIX*
else
    echo -e "\nNo regridded wrfout files found in output directory, $output_forcing_dir."
    echo -e "Exiting.\n\n"
    exit 2
fi


# clean up
echo "\n\tIMPLEMENT ME:  CLEAN UP!\n"




cd $start_dir

exit
