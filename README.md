# WRF_HYDRO-R2
*Wrapper repository to automate building, running, and visualization of WRF-Hydro v5 / NWM on BSU's R2 cluster*
<br><br><br>


## Contents
* [I. Overview](#I-Overview) - *brief description of repository*
* [II. Manifest](#II-Manifest) - *main repository structure*
* [III. Setup](#III-Setup) - *setup repository for use*
* [IV. Build Model](#IV-Build-Model) - *steps for building WRF-Hydro / NWM executable*
* [V. Domain Options](#V-Domain-Options) - *list of available Idaho NWM cut-out domains*
* [VI. Routing Options](#VI-Routing-Options) - *list of available routing configurations*
* [VII. Main Simulation Sequence](#VII-Main-Simulation-Sequence) - **main command sequence for repeated simulations**
* [VIII. Function Reference List](#VIII-Function-Reference-List) - *list of defined commands*
* [IX. Appendix](#IX-Appendix) - *links to supporting documentation*
<br><br><br>


## I. Overview
This container repository uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> repositories as submodules.  UNIX shell functions have been defined to automate core tasks and reduce them to a single command.  Further information on the WRF-Hydro model itself can be found in the WRF-HydroV5 Technical Manual<sup>[3](#3)</sup>.

Section [III. Setup](#III-Setup) details how to `clone` the repository and get it ready for use, followed by section [IV. Build Model](#IV-Build-Model), which shows how to compile the model executable.  After you've completed those steps, you can then follow the 
sequence of commands described in section [VII. Main Simulation Sequence](#VII-Main-Simulation-Sequence) to do model simulations.  This sequence of commands can easily be repeated for different input arguments to vary: routing configuration, domain, forcing type, time period, etc.  

After you feel comfortable with the steps involved for setting up a run, you should then look to customize your runs by adjusting 
relevant namelist parameters to your particular scenarios.  The two input namelist files are `hydro.namelist` and `namelist.hrldas`, 
and how to change the parameters in each is briefly described in [VII.(ii) Background Information](#VIIii-Background-Information).<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## II. Manifest
```bash
WRF_HYDRO-R2/
├── build/
│   ├── build_nwm_r2.sh                                          # model build script
│   └── env_nwm_r2.sh                                            # environment parameters, paths for build
├── funcs/
│   └── wrf_hydro_run.sh                                         # function definitions for task automation
├── LICENSE
├── namelists/
│   ├── hydro.namelist.template                                  # hydro namelist template
│   └── namelist.hrldas.template                                 # hrldas namelist template
├── post_process/
│   └── Open and Plot WRF-Hydro Output.ipynb                     # display output python script
├── pre_process 
│   ├── convert_wrf_to_wrfhydro.sh                               # wrapper script for subset, weights, regrid
│   ├── env_preprocess_r2.sh                                     # environment params, paths for pre-processing
│   ├── ncl_scripts
│   │   ├── w2wh_esmf_generate_weights.ncl                       # ncl script for regrid weight generation
│   │   └── w2wh_esmf_regrid_w_weights.ncl                       # ncl script to regrid using weights
│   ├── wrf_gen_weights_wrfhydro.sh                              # shell wrapper for ncl generate weights
│   ├── wrf_regrid_wrfhydro.sh                                   # shell wrapper for ncl regrid using weights
│   └── wrf_subset_wrfhydro.sh                                   # subsetting script
├── README.md
├── run_scripts/
│   ├── create_hrldas_namelist.sh                                # generate hrldsas namelist from template
│   └── create_hydro_namelist.sh                                 # generate hydro namelist from template
├── rwrfhydro/                                                   # git submodule: rwrfhydro repo
├── supplements/
│   ├── submit.sh.template                                       # slurm batch submission template
│   └── WRF-HydroV5TechnicalDescription_update512019_0.pdf       # wrf-hydro tech description, update: 13apr2018
└── wrf_hydro_nwm_public/                                        # git submodule: wrf_hydro_nwm_public repo
```
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## III. Setup
In a terminal logged onto R2 follow these steps to download the repository and set it up for use
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repository
cd WRF_HYDRO-R2                                              # change directory into cloned repository
source funcs/wrf_hydro_run.sh                                # load function definitions
wh_sub_mod                                                   # initialize / update submodules
wh_build_nwm                                                 # build NWM-offline executable
```
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## IV. Build Model
Assuming the steps in the previous section were successful, issue the following command to build the WRF-Hydro/NWM executable
```bash            
wh_build_nwm                                                 # build NWM-offline executable
```
The model will compile for roughly a couple minutes.  When the command prompt returns, look at the end of the text output right above it and read below to determine whether the build process was successful or not.
<br><br>

#### IV.(i) SUCCESSFUL BUILD
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
*NOTE: as shown above, both the build log and executable location are listed at the end of the build output.* 
<br><br>

#### IV.(ii) UNSUCCESSFUL BUILD: TROUBLESHOOTING
If you did not see the success message like above, and instead received a 'BUILD UNSUCCESSFUL' message, try these steps to resolve it and build again.  First, look at the build log file to locate the error.  Once you've done that, apply the necessary fix.  If you've completed that, you just need to clean out the build directory, then try building again as below,
```bash
wh_clean_nwm                                                   # clean out previous NWM build
wh_build_nwm                                                   # try building NWM executable again
```
<br>

#### IV.(iii) Background Information
The script containing the parameters for building the WRF-Hydro executable is called `setEnvar.sh`, and is
located in `wrf_hydro_nwm_public/trunk/NDHMS/template`.  The build script starts by making a copy of `setEnvar.sh`
in the directory `wrf_hydro_nwm_public/trunk/NDHMS`.  Next, the build script calls the compile script in the NWM repo, 
`compile_offline_NoahMP.sh`, and supplies `setEnvar.sh` as the one input argument.  As described above, a successful
build results in a new directory being generated called `wrf_hydro_nwm_public/trunk/NDHMS/Run`.  This directory
contains the executable, `wrf_hydro_NoahMP.exe`, as well as the two namelist files, `hydro.namelist` and `namelist.hrldas`,
which are generated based on the parameters set in `setEnvar.sh`.  The run directory also contains several other auxiliary files needed by the
executable at runtime.  A copy of this entire directory is made when the command `wh_run_dir` (described below) is 
executed.  *NOTE: In addition to cleaning out the build location to try another build, the command* `wh_clean_nwm` *returns
the* `wrf_hydro_nwm_public` *repo to it's original, unmodified state for purposes of version control*.<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## V. Domain Options
Currently provided Idaho cut-out domains from the National Water Model and their reference numbers can be displayed 
by calling
```bash
wh_list_domain
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
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## VI. Routing options
The routing options available and their reference numbers can be displayed by calling
```bash
wh_list_routing
```
```bash
        NUM:   Routing Opt. -  Description
        ----------------------------------------------------
          0:   LSM          -  NoahMP Land Surface Model [selected by default]
          1:   SUB          -  Subsurface Flow Routing
          2:   OVR          -  Overland Flow Routing
          3:   CHL          -  Channel Routing
          4:   RES          -  Lakes/Reservoir Routing
          5:   GWB          -  Groundwater/baseflow Routing
```
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## VII. Main Simulation Sequence
Once you have cloned the repository and built the executable, then you are set up to easily do model 
simulations.  As an aside, when you log in and out from your R2 sessions you will not (in general) need to
re-clone or re-build the WRF-Hydro model (executable).  You will however need to `source` the
functions file each time you log in, as below, where it's assumed you're in the root directory of
the repository
```bash
source funcs/wrf_hydro_run.sh                                # load function definitions
```
Once that is done for a session, you can proceed with doing runs.  These six core commands are
the sequence you should follow, 
```bash
wh_run_dir      <run_id>                                   # create run directory, copy exe + aux files
wh_domain       <run_id> <domain_id>                       # copy cutout to DOMAIN/
wh_forcing      <run_id> <input_dir> <geogrid_file>        # subset + regrid forcing to FORCING/
wh_hydro_nlist  <run_id> <routing_opts>                    # create hydro.namelist w routing opts
wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours> # create namelist.hrldas w simulation period
wh_job          <run_id> <queue_name> <minutes> <cores>    # create batch job submit script
```
You can repeat those sequence of commands to continue to do different simulations.  The last command above, 
`wh_job`, will create a SLURM script (`submit`) for a batch job in the run directory.  Also, just before it 
returns the command prompt, it will print out the command (starting with `sbatch`) needed to submit the 
job to the scheduler.  This is done so you have the opportunity once everything else is ready to run 
to make any adjustments, if any, before running it.  If not, simply copy and paste that command and your job 
will be added to the scheduler's queue to be run as a batch job.
<br><br>

#### VII.(i) Example Usage
* `wrf_run_dir     test000` - any unique string to distinquish the run directory created in `/scratch/auser`.
* `wh_domain       test000  3` - number identifier listed in the left-most column of output from the command `wh_list_domain`.
* `wh_forcing      test000  /scratch/auser/WRF_Run/d01  /scratch/auser/WH_SIM_test000/DOMAIN/geo_em.d01.nc` - Full path to 
forcing file directory and (routing grid scale) geogrid file.  This geogrid file will be located in the `DOMAIN/` 
sub-directory of the run directory, after you have issued the previous command, `wh_domain`.
* `wh_hydro_nlist  test000  1  3  4` - any combination of the available routing options: `0 1 2 3 4 5` (Note, 0 - NoahMP LSM is always 
selected by default, you may list the 0 or leave it out).
* `wh_hrldas_nlist test000  2010  06  02  00  72` - the year, month, day, and hour start time, followed by the simulation time period
in hours.  These date values are contained in the file name of the first chronological file located in the `FORCING/` directory after you have run, `wh_forcing`.  The simulation time period is the difference in hours of the first and last forcing file.
* `wh_job          test000  defq  15  4` - name of R2 queue to use, wallclock time for job to run in minutes, number of cores requested.
<br><br>

#### VII.(ii) Background Information
The command `wh_hydro_nlist` calls a script (`run_scripts/create_hydro_namelist.sh`) that modifies a template file (`namelists/hydro.namelist.template`), producing `hydro.namelist`.  This file contains parameters that are read by the model at runtime.  Among other things, it controls the hydrological routing options and their associated parameters to be used in the run.  The command `wh_hrldas_nlist` calls a script (`run_scripts/create_hrldas_namelist.sh`) that modifies a template file (`namelists/namelist.hrldas.template`), producing `namelist.hrldas`.  Among other things, it specifies the parameters to be used in the NoahMP LSM and the period of simulation for the run.

To adjust parameters in the `hydro.namelist` you can modify the creation script, `create_hydro_namelist.sh`, or for quick experimentation you can hard-code values directly in the template file, `hydro.namelist.template`.  Analogously, for the HRLDAS namelist edit the file `create_hrldas_namelist.sh`, or the template file, `namelist.hrldas.template`.<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## VIII. Function Reference List
A list of the available commands can be displayed by entering `wh_list`, the output of which is below
```bash
  wh_dev          <queue_name> <minutes>                      # slurm request interactive compute session

  wh_sub_mod                                                  # init/update submodules
  wh_build_nwm                                                # compile wrf-hydro/nwm executable
  wh_clean_nwm                                                # clean out nwm build

  wh_run_dir      <run_id>                                    # create run directory, copy exe + aux files
  wh_domain       <run_id> <domain_id>                        # copy cutout to DOMAIN/
  wh_forcing      <run_id> <input_dir> <geogrid_file>         # subset + regrid forcing files to FORCING/
  wh_hydro_nlist  <run_id> <routing_opts>                     # create hydro.namelist w routing options
  wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours>  # create namelist.hrldas w simulation period
  wh_job          <run_id> <queue_name> <minutes> <cores>     # create slurm batch submit script

  wh_list                                                     # list wrf-hydro defined functions
  wh_list_domain                                              # list wrf-hydro cutout domains
  wh_list_routing                                             # list routing/physics options
```
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## IX. Appendix
* <sup><a name="1">1</a></sup> [Github: NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [Github: NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
* <sup><a name="3">3</a></sup> [WRF-Hydro V5 Technical Description](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/supplements/WRF-HydroV5TechnicalDescription_update512019_0.pdf)
* [NCAR RAL: WRF-Hydro Home Page](https://ral.ucar.edu/projects/wrf_hydro/overview)
* [NOAA OWP: National Water Model](https://water.noaa.gov/about/nwm)
<br>

[Return to top](#WRF_HYDRO-R2)
