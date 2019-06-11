# WRF_HYDRO-R2
*Wrapper repository to automate build + run + visualize WRF-Hydro v5 / NWM on R2*
<br><br><br><br>


## Contents
* [I. Overview](#I-Overview) - *brief description of repository*
* [II. Manifest](#II-Manifest) - *main repository structure*
* [III. Build](#III-Build) - *steps for building WRF-Hydro / NWM*
* [IV. Test Case: Croton NY](#IV-Test-Case-Croton-NY) - *steps to setup + run the test case Croton, NY*
* [V. Idaho NWM Cut-outs](#V-Idaho-NWM-Cut-outs) - *Idaho cut-outs from NWM*
* [VI. Make Target Reference](#VI-Make-Target-Reference) - *reference list of all supported `make` commands*
* [VII. Appendix](#VII-Appendix) - *links to extended, internal documentation*
* [VIII. Links](#VIII-Links) - *links to external references*

<br>


## I. Overview
This container repository uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> repositories as submodules. The *GNU Make*<sup>[3](#3)</sup> utility is used to automate core tasks and reduce them to a single command. The `make` commands must be issued from the repository root directory, `WRF_HYDRO-R2/`.
<br><br>

## II. Manifest
```bash
WRF_HYDRO-R2/
├── LICENSE
├── Makefile
├── namelists/                               
│   ├── hydro.namelist.custom_forcing
│   ├── hydro.namelist.idealized_forcing
│   ├── namelist.hrldas.custom_forcing
│   ├── namelist.hrldas.idealized_forcing
│   └── README_NAMELISTS.md
├── prep_input/
│   ├── convert_wrf_to_wrfhydro.sh           # main pre-process script
│   ├── env_subset_r2.sh
│   ├── ncl_scripts/
│   │   ├── w2wh_esmf_generate_weights.ncl
│   │   └── w2wh_esmf_regrid_w_weights.ncl
│   ├── README_CONVERT.md
│   ├── wrf_gen_weights_wrfhydro.sh
│   ├── wrf_regrid_wrfhydro.sh
│   └── wrf_subset_wrfhydro.sh
├── README.md
├── rwrfhydro/                               # rwrfhydro repository
├── scripts/
│   ├── build_nwm_r2.sh                      # build script
│   ├── croton_ny_setup.sh                   # download + setup croton_NY test case
│   ├── env_nwm_r2.sh                        # NWM environment script
│   ├── README_BUILD.md
│   └── submit.sh.template                   # SLURM batch template
└── wrf_hydro_nwm_public/                    # WRF-Hydro v5 / NWM repository
```
<br>

## III. Build
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repository
cd WRF_HYDRO-R2                                              # go into repository
source scripts/env_nwm_r2.sh                                 # source r2 environment
make sub                                                     # initialize / update submodules
make build                                                   # build NWM-offline executable
```
**NOTE: Make sure to source the environment script as shown above.  This loads the correct modules as well as                          
exports needed `PATH` variables.** 
<br>

Sample output at the end of a successful build by username, `auser`, looks like the following
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
submitted as a batch job using the following commands
```bash
make test               # setup test, must be run after 'make build'
```
After running `make test`, sample output text at completion of setup will look similar to this
```bash

	** Croton_NY Testcase setup finished. **
	----------------------------------------
	Run directory: /home/mmasarik/LEAF/WRF_HYDRO-R2/croton_NY/NWM
	Run command:   make run
```
*Note: The 'Run directory' listed is where you will find all the output files generated by the run
(after you do `make run`).  The 'run command' `make run` should still be issued in the repository
root directory, WRF_HYDRO-R2, like all other `make` commands.*

Now to submit a batch job to the SLURM scheduler, issue the following
```bash
make run                # submit batch job to run test case, croton_NY 
```
After running this command the text displayed to the screen will look like this
```bash
sbatch croton_NY/NWM/submit
Submitted batch job 137663
```
To check on the run status in the queue, use the SLURM command `squeue` with `-j` option followed by the job batch number,
here this number is 137663.  For this job we would use
```bash
squeue -j 137663
```
Once the run has finished, to verify the run was successful, navigate to the Run directory, then look at the end of the run log file, the default run log file is named '`whcroton.log`'.  Log file text for a successful Croton, NY simulation 
will look like the following
```bash
 ...
 ***DATE=2011-09-02_00:00:00 294.95029   2.25479    Timing:   0.22 Cumulative:       36.38  SFLX:   0.00
 ***DATE=2011-09-02_00:00:00 294.31494   2.25479    Timing:   0.22 Cumulative:       36.38  SFLX:   0.00
 ***DATE=2011-09-02_00:00:00 294.40228   2.25479    Timing:   0.22 Cumulative:       36.38  SFLX:   0.00
 The model finished successfully.......
 The model finished successfully.......
 The model finished successfully.......
 The model finished successfully.......
```
In this case there are 4 lines that say 'The model finished successfully.......' -- there is one line for each
core/task used.  The default value of 4 can be changed in the script: `scripts/croton_ny_setup.sh`.  Open it with
a text editor and you should see the following user parameters near the top
```bash
...
# USER PARAMETERS - CHANGE ME!
NUM_CORES=4                     # mpi tasks: 1-28          [4         default]
QUEUE_TIME='00:10:00'           # runtime:   hh:mm:ss      [00:10:00  default]
QUEUE_NAME=defq                 # queue:                   [defq      default]
JOB_NAME='whcroton'             # jobname:   8 chars only for display in queue
```
These four parameters can be adjusted to your liking.  

After `make test` and `make run` have been issued, you can use `make clean_test`
to remove the run output files from test run directory.  You can then do another run using 
that same setup test directory by issuing `make run` again, possibly after
editting the namelists in the displayed run directory to experiment with different
options.
<br><br>



## V. Idaho NWM Cut-outs
Currently provided cut-outs from the National Water Model and their reference numbers can be displayed 
by calling

```bash
make list_cutout
```

```bash
	NUM:   Gauge ID  -  Description
	----------------------------------------------------
          1:   13139510  -  Big Wood River at Hailey ID
          2:   13168500  -  Bruneau River near Hot Springs ID
          3:   13185000  -  Boise River near Twin Springs ID
          4:   13186000  -  SF Boise River near Featherville ID
	  5:   13235000  -  SF Payette River at Lowman ID
          6:   13237920  -  MF Payette River near Crouch ID
          7:   13258500  -  Weiser River near Cambridge ID
          8:   13316500  -  Little Salmon River at Riggins ID
```

You can then make a copy of a cut-out run directory by calling `make copy_cutout NUM=<num>`, 
where `<num>` specifies the number ID of the basin [1-8].  For example, to create a copy of the MF Payette River
near Cambridge ID (13237920), the call would be
```bash
make copy_cutout NUM=6
```
<br>

                                                             
## VI. Make Target Reference
```bash                        
make                        # default, calls target sub
make help                   # display make target reference list
make sub                    # initializes and updates submodule NWM
make build                  # builds the NoahMP/NWM-Offline exe
make test                   # get and setup croton_NY test case
make run                    # run the croton_NY test case
make list_cutout            # display reference list of cut-outs with number ID's
make copy_cutout NUM=<num>  # create a copy of cutout directory for number ID <num> 
make clean_test             # cleans all run output from croton_NY test
make clean_nwm              # calls the 'make clean' target in NWM build dir
```
<br>


## VII. Appendix
* [README_BUILD.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/scripts/README_BUILD.md) - details on build process
* [README_CONVERT.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/prep_input/README_CONVERT.md) - details on data pre-processing scripts
* [README_NAMELISTS.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/namelists/README_NAMELISTS.md) - details on namelist options
<br>

                                                                             
## VIII. Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
* <sup><a name="3">3</a></sup> [GNU Make manual](https://www.gnu.org/software/make/manual/)
* <sup><a name="4">4</a></sup> [WRF-Hydro Testcases](https://ral.ucar.edu/projects/wrf_hydro/testcases) - See '*Croton New York Test Case*'
<br>

[Return to top](#WRF_HYDRO-R2)
