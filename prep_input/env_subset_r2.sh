#!/bin/bash

# *****************************************************************************
# FILE:     env_subset_r2.sh
# AUTHOR:   Matt Masarik      (MM) 
# VERSION:  0     2019-02-22   MM    Base version
#
# PURPOSE:  Provides evironment variables and modules required for 
#           subsetting WRF output to WRF-Hydro input files on R2.
#
# USAGE:    source env_subset_r2.sh
# *****************************************************************************

# unload any auto-loaded modules
module purge

# now load modules
module load shared
module load git/64/2.12.2
module load slurm/17.11.8
module load gcc/6.4.0
module load intel/compiler/64/2017/17.0.7
module load intel/mkl/64/2017/7.259
module load hdf5_18/1.8.20
module load netcdf/intel/64/4.4.1
module load udunits/intel/64/2.2.24
module load gsl/intel/2.3
module load nco/64/4.6.2
module load ncl/64/6.4

# export netCDF env variable
export NETCDF=/cm/shared/apps/netcdf/intel/64/4.4.1

