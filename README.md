# WRF_HYDRO-R2
*Wrapper repository to automate build + run + vis for WRF-Hydro v5 / NWM on R2*
<br>

## Objective
This container uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> repos as submodules.
<br>


## Manifest
```bash
WRF_HYDRO-R2/
├── LICENSE
├── Makefile
├── README.md
├── scripts
│   ├── build_nwm_r2.sh           # build script
│   ├── croton_ny_testcase.sh     # get/run croton_NY test
│   ├── env_nwm_r2.sh             # environment script
│   └── submit.sh.template        # SLURM batch template
└── wrf_hydro_nwm_public
```

## Build
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repo
cd WRF_HYDRO-R2                                              # go into repo
source scripts/env_nwm_r2.sh                                 # source r2 environment
make sub                                                     # init/update submodules
make build                                                   # build NWM-offline exe
```

Sample output at the end of a successful build by username, `auser`, looks like the following:
```bash
...
make[3]: Leaving directory '/home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/Land_models/NoahMP/run'
make[2]: Leaving directory '/home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/Land_models/NoahMP'
make[1]: Leaving directory '/home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS'

*****************************************************************
Make was successful

*****************************************************************
The environment variables used in the compile:
HYDRO_D=0
NCEP_WCOSS=0
NETCDF=/cm/shared/apps/netcdf/intel/64/4.4.1
OLDPWD=/home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS
PWD=/home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/Run
SPATIAL_SOIL=1
WRF_HYDRO=1
WRF_HYDRO_NUDGING=1
WRF_HYDRO_RAPID=0
WRFIO_NCD_LARGE_FILE_SUPPORT=1


	** BUILD SUCCESSFUL!!! **
	Log file: /home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/WH_R2_noahMP_compile.log
	Returning to initial directory, /home/auser/LEAF/WRF_HYDRO-R2.
```

If you received a 'BUILD UNSUCCESSFUL' message from the `make build` step (assuming the preceding steps were successful), try these
steps to troubleshoot.  First, assess what went wrong from looking at the build log file, the path will be given just below the
UNSUCCESSFUL message.  Next, make any necessary changes to address the problem.  Lastly, clean out the build directory and re-issue
the build command, e.g. (assuming you are back in the top-level dir, WRF_HYDRO-R2):
```bash
make clean                                                   # calls make clean in build dir
make build                                                   # build NWM-offline exe
```
<br>


## Run Test Case: Croton NY
The example test case for Croton, NY<sup>[3](#3)</sup> will be downloaded, set up, and 
submitted as a batch job using the commands
```bash
make test               # setup test, must be run after 'make build'
make run                # run the test case, croton_NY 
```
At the end of the output of `make test`, the run directory full path is displayed.
After `make test` and `make run` have been issued, you can use `make clean_test`
to clean all the run output from test run directory.  You can then do another run by 
with the same setup test directory by issuing `make run` again, possibly after
editting the namelists in the displayed run directory to experiment with different
options.
<br>

                                                             
## Make Target Reference
```bash                        
make                    # default, calls target sub
make sub                # initializes and updates submodule NWM
make build              # builds the NoahMP/NWM-Offline exe
make test               # get and setup croton_NY test case
make run                # run the croton_NY test case
make clean_test         # cleans all run output from croton_NY test
make clean              # calls the 'make clean' target in NWM build dir
```
                                                                             
## Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
* <sup><a name="3">3</a></sup> [WRF-Hydro Testcases](https://ral.ucar.edu/projects/wrf_hydro/testcases) - See 'Croton New York Test Case'

