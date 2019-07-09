# WRF_HYDRO-R2
*Wrapper repository to automate build + run + visualize WRF-Hydro v5 / NWM on R2*
<br><br><br><br>


## Contents
* [I. Overview](#I-Overview) - *brief description of repository*
* [II. Manifest](#II-Manifest) - *main repository structure*
* [III. Build](#III-Build) - *steps for building WRF-Hydro / NWM*
* [IV. Idaho NWM Cut-outs](#IV-Idaho-NWM-Cut-outs) - *available Idaho watershed domains from NWM*
* [V. Routing Options](#V-Routing-Options) - *list of available routing configurations*
* [VI. Main Simulation Sequence](#VI-Main-Simulation-Sequence) - **main command sequence for repeated simulations**
* [VII. Function Reference List](#VII-Function-Reference-List) - *list of defined commands*
* [VIII. Appendix](#VIII-Appendix) - *links to extended, internal documentation*
* [IX. Links](#IX-Links) - *links to external references*

<br>


## I. Overview
This container repository uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> repositories as submodules. UNIX shell functions have been defined to automate core tasks and reduce them to a single command.
<br><br>

## II. Manifest
```bash
WRF_HYDRO-R2/
├── build/
│   ├── build_nwm_r2.sh
│   ├── env_nwm_r2.sh
│   └── README_BUILD.md
├── funcs/
│   └── wrf_hydro_run.sh
├── LICENSE
├── namelists/
│   ├── hydro.namelist.custom_forcing
│   ├── hydro.namelist.idealized_forcing
│   ├── hydro.namelist.lsm_ovr_chl
│   ├── namelist.hrldas.custom_forcing
│   ├── namelist.hrldas.idealized_forcing
│   ├── namelist.hrldas.lsm_ovr_chl
│   └── README_NAMELISTS.md
├── post_process/
├── pre_process/
│   ├── convert_wrf_to_wrfhydro.sh
│   ├── env_preprocess_r2.sh
│   ├── ncl_scripts/
│   │   ├── w2wh_esmf_generate_weights.ncl
│   │   └── w2wh_esmf_regrid_w_weights.ncl
│   ├── README_PREPROCESS.md
│   ├── wrf_gen_weights_wrfhydro.sh
│   ├── wrf_regrid_wrfhydro.sh
│   └── wrf_subset_wrfhydro.sh
├── README.md
├── rwrfhydro/
├── supplements/
│   └── submit.sh.template
└── wrf_hydro_nwm_public/
```
<br>

## III. Build
In a terminal follow these steps to download the repository, set it up, and build the WRF-Hydro/NWM executable,
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repository
cd WRF_HYDRO-R2                                              # go into repository
source funcs/wrf_hydro_run.sh                                # load function definitions
wh_sub_mod                                                   # initialize / update submodules
wh_build                                                     # build NWM-offline executable
```
<br>
After issuing the last command, the model will be compiling for rougly a couple minutes.  When the command prompt returns, look at the end of the text output right above it and read below to determine whether it was successful or not.


#### SUCCESSFUL BUILD
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
<br>

*NOTE: as shown above, both the build log and executable location are listed at the end of the build output.* 


#### UNSUCCESSFUL BUILD: TROUBLESHOOTING
If you did not see the success message like above, and instead received a 'BUILD UNSUCCESSFUL' message, try these steps to resolve it and build again.  First, look at the build log file to locate the error.  Once you've done that, apply the necessary fix.  If you've completed that, you just need to clean out the build directory, then try building again as below,

```bash
wh_clean_nwm                                                   # clean out previous NWM build
wh_build                                                       # try building NWM executable again
```
<br>



## IV. Idaho NWM Cut-outs
Currently provided cut-outs from the National Water Model and their reference numbers can be displayed 
by calling

```bash
wh_list_dom
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
<br>


## V. Routing options
The routing options available and their reference numbers can be displayed by calling
```bash
wh_list_rto
```

```bash
        NUM:     Routing option   -  Description
        ----------------------------------------------------
          1:     lsm              -  NoahMP LSM
          2:     lsm_sub          -  NoahMP LSM + Subsurface routing
          3:     lsm_ovr          -  NoahMP LSM + Overland surface flow routing
          4:     lsm_chl          -  NoahMP LSM + Channel routing
          5:     lsm_res          -  NoahMP LSM + Lake/reservoir routing
          6:     lsm_gwb          -  NoahMP LSM + Groundwater/baseflow model
          7:     lsm_ovr_chl      -  NoahMP LSM + Overland surface flow routing + Channel routing
```
<br>


## VI. Main Simulation Sequence
Once you have cloned the repository and built the executable, then you are set up to easily do
repeated runs.  When you log in and out from your R2 sessions, you will not (in general) need to
re-clone or re-build the WRF-Hydro model (executable).  You will however need to `source` the
functions file each time you log in, as below, where it's assumed you're in the root directory of
the repository
```bash
source funcs/wrf_hydro_run.sh                                # load function definitions
```
Once that is done for a session, you can proceed with doing runs.  These five core commands are
the sequence you should follow,
```bash
wh_run_dir  <run_id>                                   # create wrf-hydro run (parent) directory
wh_run_dom  <run_id> <domain_id>                       # create DOMAIN from cutout in run dir
wh_run_rto  <run_id> <routing_opt>                     # copy exe + associated files to run dir
wh_run_frc  <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING
wh_run_job  <run_id> <yyyy> <mm> <dd> <hh> <sim_days>  # set namelist sim time and submit job
```
The last command above, `wh_run_job`, will set the simulation times as well as information for a batch
job in a SLURM script (`submit`) in the run directory.  Also, just before it returns the command prompt, it will
print out the command (starting with `sbatch`) needed to submit the job to the scheduler.  This is done so
you have the opportunity now, once everything else is ready to run, to make any adjustments if any before
running it.  If not, simply copy and paste that command to run it and your job will be added to the queue.
Repeat those steps to continue to do different simulations.
<br><br><br>


## VII. Function Reference List
A list of the available commands can be displayed by entering `wh_list`, the output of which is below
```bash
wh_list
```
```bash
wh_dev      <queue_name> <minutes>                     # slurm request interactive compute session

wh_sub_mod                                             # init/update submodules
wh_build                                               # compile the wrf-hydro/nwm executable
wh_clean_nwm                                           # clean NWM repo build

wh_run_dir  <run_id>                                   # create wrf-hydro run (parent) directory
wh_run_dom  <run_id> <domain_id>                       # create DOMAIN from cutout in run dir
wh_run_rto  <run_id> <routing_opt>                     # copy exe + associated files to run dir
wh_run_frc  <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING
wh_run_job  <run_id> <yyyy> <mm> <dd> <hh> <sim_days>  # set namelist sim time and submit job

wh_list                                                # list wrf-hydro defined functions
wh_list_dom                                            # list wrf-hydro cutout domains
wh_list_rto                                            # list routing/physics options
```
<br>


## VIII. Appendix
* [README_BUILD.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/build/README_BUILD.md) - details on build process
* [README_CONVERT.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/pre_process/README_CONVERT.md) - details on data pre-processing scripts
* [README_NAMELISTS.md](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/namelists/README_NAMELISTS.md) - details on namelist options
<br>

                                                                             
## IX. Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
<br>

[Return to top](#WRF_HYDRO-R2)
