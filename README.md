# WRF_HYDRO-R2
*Wrapper repository to automate build + run + visualize WRF-Hydro v5 / NWM on R2*
<br><br><br><br>


## Contents
* [I. Overview](#I-Overview) - *brief description of repository*
* [II. Manifest](#II-Manifest) - *main repository structure*
* [III. Build](#III-Build) - *steps for building WRF-Hydro / NWM*
* [IV. Test Case: Croton NY](#IV-Test-Case-Croton-NY) - *steps to setup + run the test case Croton, NY*
* [V. Make Target Reference](#V-Make-Target-Reference) - *reference list of all supported `make` commands*
* [VI. Links](#VI-Links) - *links to external references*
<br>


## I. Overview
This container repository uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> (*rwrfhydro support coming soon*) repositories as submodules. The *GNU Make*<sup>[3](#3)</sup> utility is used to automate core tasks and reduce them to a single command. The `make` commands must be issued from the repository root directory, `WRF_HYDRO-R2/`.
<br><br>

## II. Manifest
```bash
WRF_HYDRO-R2/
├── LICENSE
├── Makefile
├── README.md
├── scripts
│   ├── build_nwm_r2.sh           # build script
│   ├── croton_ny_testcase.sh     # download + setup croton_NY test case
│   ├── env_nwm_r2.sh             # environment script
│   └── submit.sh.template        # SLURM batch template
└── wrf_hydro_nwm_public/         # WRF-Hydro v5 / NWM repository
```
<br>

## III. Build
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repository
cd WRF_HYDRO-R2                                              # go into repository
source scripts/env_nwm_r2.sh                                 # source r2 environment script
make sub                                                     # initialize / update submodules
make build                                                   # build NWM-offline executable
```
**NOTE: Make sure to source the environment script as shown above.  This loads the correct modules as well as 
exports needed `PATH` variables.**
<br>

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
	-------------------------
	Executable: /home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/Run/wrf_hydro_NoahMP.exe
	Log file:   /home/auser/LEAF/WRF_HYDRO-R2/wrf_hydro_nwm_public/trunk/NDHMS/WH_R2_noahMP_compile.log
```


*NOTE: both the build log and executable location are listed at the end of the build output.* If you received a 'BUILD UNSUCCESSFUL' message from the `make build` step (assuming the preceding steps were successful), try these steps to troubleshoot.  First, assess what went wrong from looking at the build log file.  Next, make any necessary changes to address the problem.  Lastly, clean out the build directory and re-issue the build command, e.g. (assuming you are back in the top-level directory, WRF_HYDRO-R2):

```bash
make clean                                                   # calls make clean in build directory
make build                                                   # build NWM-offline executable
```
<br>

## IV. Test Case: Croton NY
The example test case for Croton, NY<sup>[4](#4)</sup> will be downloaded, set up, and 
submitted as a batch job using the commands
```bash
make test               # setup test, must be run after 'make build'
make run                # run the test case, croton_NY 
```
At the end of the output of `make test`, the run directory full path is displayed where you will find
all the output files generated from the run.
After `make test` and `make run` have been issued, you can use `make clean_test`
to remove the run output files from test run directory.  You can then do another run using 
that same setup test directory by issuing `make run` again, possibly after
editting the namelists in the displayed run directory to experiment with different
options.
<br><br>
                                                             
## V. Make Target Reference
A GNU Make command is composed of the `make` invocation (possibly) followed by a '*target*', such as
`sub`, `build`, etc. seen below.
```bash                        
make                    # default, calls target sub
make sub                # initializes and updates submodule NWM
make build              # builds the NoahMP/NWM-Offline exe
make test               # get and setup croton_NY test case
make run                # run the croton_NY test case
make clean_test         # cleans all run output from croton_NY test
make clean              # calls the 'make clean' target in NWM build dir
```
<br>
                                                                             
## VI. Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
* <sup><a name="3">3</a></sup> [GNU Make manual](https://www.gnu.org/software/make/manual/)
* <sup><a name="4">4</a></sup> [WRF-Hydro Testcases](https://ral.ucar.edu/projects/wrf_hydro/testcases) - See '*Croton New York Test Case*'
<br>

[Return to top](#WRF_HYDRO-R2)
