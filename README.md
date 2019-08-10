# WRF_HYDRO-R2
*Wrapper repository to automate building, running, and visualization of WRF-Hydro v5 / NWM on BSU's R2 cluster*
<br><br><br>


## Contents
* [I. Overview](#I-Overview) - *brief description of repository*
* [II. Manifest](#II-Manifest) - *main repository structure*
* [III. Build](#III-Build) - *steps for building WRF-Hydro / NWM executable*
* [IV. Idaho NWM Cut-outs](#IV-Idaho-NWM-Cut-outs) - *list of available Idaho watershed domains from NWM*
* [V. Routing Options](#V-Routing-Options) - *list of available routing configurations*
* [VI. Main Simulation Sequence](#VI-Main-Simulation-Sequence) - **main command sequence for repeated simulations**
* [VII. Function Reference List](#VII-Function-Reference-List) - *list of defined commands*
* [VIII. Appendix](#VIII-Appendix) - *links to supporting documentation*
<br><br><br>


## I. Overview
This container repository uses the NCAR NWM<sup>[1](#1)</sup> and rwrfhydro<sup>[2](#2)</sup> repositories as submodules. UNIX shell functions have been defined to automate core tasks and reduce them to a single command.  Further information can be found in the WRF-HydroV5 Technical Manual<sup>[3](#3)</sup>.

The main tasks involved are as follows.  First `clone` this repository then build the model which produces a run directory with the
WRF-Hydro/NWM executable. This complete process is described below in the [III. Build](#III-Build) section.  Next, follow the a
sequence of six commands described in the section, [VI. Main Simulation Sequence](#VI-Main-Simulation-Sequence).  These commands can easily
be repeated for different input arguments to vary, routing configurations, domains, forcing types, time periods, etc.  Exploring beyond the
commands you may want to experiment with modifying default parameter values for variables of interest found in the two input namelist files,
`hydro.namelist` and `namelist.hrldas`.<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br><br>


## II. Manifest
```bash
WRF_HYDRO-R2/
├── build/
│   ├── build_nwm_r2.sh
│   └── env_nwm_r2.sh
├── funcs/
│   └── wrf_hydro_run.sh
├── LICENSE
├── namelists/
│   ├── hydro.namelist.template
│   └── namelist.hrldas.template
├── post_process/
│   └── Open and Plot WRF-Hydro Output.ipynb
├── pre_process
│   ├── convert_wrf_to_wrfhydro.sh
│   ├── env_preprocess_r2.sh
│   ├── ncl_scripts
│   │   ├── w2wh_esmf_generate_weights.ncl
│   │   └── w2wh_esmf_regrid_w_weights.ncl
│   ├── wrf_gen_weights_wrfhydro.sh
│   ├── wrf_regrid_wrfhydro.sh
│   └── wrf_subset_wrfhydro.sh
├── README.md
├── run_scripts/
│   ├── create_hrldas_namelist.sh
│   └── create_hydro_namelist.sh
├── rwrfhydro/
├── supplements/
│   ├── submit.sh.template
│   └── WRF-HydroV5TechnicalDescription_update512019_0.pdf
└── wrf_hydro_nwm_public/
```
[Return to top](#WRF_HYDRO-R2)
<br><br><br>


## III. Build
In a terminal follow these steps to download the repository, set it up, and build the WRF-Hydro/NWM executable,
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repository
cd WRF_HYDRO-R2                                              # go into repository
source funcs/wrf_hydro_run.sh                                # load function definitions
wh_sub_mod                                                   # initialize / update submodules
wh_build_nwm                                                 # build NWM-offline executable
```
After issuing the last command, the model will be compiling for rougly a couple minutes.  When the command prompt returns, look at the end of the text output right above it and read below to determine whether it was successful or not.
<br><br><br>

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
*NOTE: as shown above, both the build log and executable location are listed at the end of the build output.* 
<br><br><br>

#### UNSUCCESSFUL BUILD: TROUBLESHOOTING
If you did not see the success message like above, and instead received a 'BUILD UNSUCCESSFUL' message, try these steps to resolve it and build again.  First, look at the build log file to locate the error.  Once you've done that, apply the necessary fix.  If you've completed that, you just need to clean out the build directory, then try building again as below,
```bash
wh_clean_nwm                                                   # clean out previous NWM build
wh_build_nwm                                                   # try building NWM executable again
```
<br>

#### Background Information
The script containing the parameters for building the WRF-Hydro executable is called `setEnvar.sh`, and is
located in `wrf_hydro_nwm_public/trunk/NDHMS/template`.  The build script starts by making a copy of `setEnvar.sh`
in the directory `wrf_hydro_nwm_public/trunk/NDHMS`.  Next, the build script calls the compilation script 
`compile_offline_NoahMP.sh` and supplies `setEnvar.sh` as the one input argument.  As described above, a successful
build results in a new directory being generated called `wrf_hydro_nwm_public/trunk/NDHMS/Run`.  This directory
contains the executable, `wrf_hydro_NoahMP.exe`, as well as the two namelist files, `hydro.namelist` and `namelist.hrldas`,
which are generated based on the parameters set in `setEnvar.sh`.  The run directory also contains several other auxiliary files needed by the
executable at runtime.  A copy of this entire directory is made when the command `wh_run_dir` (described below) is 
executed.  *NOTE: In addition to cleaning out the build location to try another build, the command* `wh_clean_nwm` *returns
the* `wrf_hydro_nwm_public` *repo to it's original, unmodified state for purposes of version control*.<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br>



## IV. Idaho NWM Cut-outs
Currently provided cut-outs from the National Water Model and their reference numbers can be displayed 
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


## V. Routing options
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


## VI. Main Simulation Sequence
Once you have cloned the repository and built the executable, then you are set up to easily do
repeated runs.  When you log in and out from your R2 sessions, you will not (in general) need to
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
wh_hydro_nlist  <run_id> [<0 ... 5>]                       # create hydro.namelist w routing opts
wh_hrldas_nlist <run_id> <yyyy> <mm> <dd> <hh> <sim_hours> # create namelist.hrldas w simulation period
wh_job          <run_id> <queue_name> <minutes> <cores>    # create batch job submit script
```
You can repeat those sequence of commands to continue to do different simulations.  The last command above, 
`wh_job`, will create a SLURM script (`submit`) for a batch job in the run directory.  Also, just before it 
returns the command prompt, it will print out the command (starting with `sbatch`) needed to submit the 
job to the scheduler.  This is done so you have the opportunity once everything else is ready to run 
to make any adjustments, if any, before running it.  If not, simply copy and paste that command to run it 
and your job will be added to the queue.
<br><br>

#### Input Args
###### wh_run_dir
`<run_id>` - any unique string to distinquish the run directory created in `/scratch`.<br>
Ex. - `test000`.
<br>

###### wh_domain
`<domain_id>` - number identifier listed in the left-most column of the output from the command
`wh_list_domain`.<br>
Ex. - `4`
<br>

###### wh_forcing
`<input_dir>` - the full path to a directory containing WRF output files (wrfout's).<br>
Ex. - `/scratch/auser/WRF_Runs/June_2010/d01`.
<br>
`<geogrid_file>` - the full path to a geogrid file specifying the cutout domain. This file
will be located in the `DOMAIN/` sub-directory of the run directory, after you have issued
the prevous command, `wh_forcing`.<br>
Ex. - `/scratch/auser/WH_SIM_test000/DOMAIN/geo_em.d01.nc`.
<br>

###### wh_hydro_nlist
`[<0 ... 5>]` - any combination of the available routing options: `0 1 2 3 4 5` (Note, 0 - NoahMP LSM is always 
selected by default, you may list the 0 or leave it out).<br>
Ex. - `1 3 4`
<br>

###### wh_hrldas_nlist
`<yyyy> <mm> <dd> <hh>` - the year, month, day, and hour start time.  These values are contained in the file name
of the first chronological file located in the `FORCING/` directory after you have run, `wh_forcing`.<br>
Ex. - `2010 06 02 00`.
<br>
`<sim_hours>` - number of simulation hours to run.  This will be the difference in hours of the first forcing
file and the last.  The forcing files are found in the `FORCING/` directory after running, `wh_forcing`.<br>
Ex. - `72`.
<br>

###### wh_job
`<queue_name>` - name of R2 queue to use.  Everyone has access to `defq` (general purpose), 
and `shortq` (testing).<br>
Ex. - `defq`.
<br>
`<minutes>` - wallclock time for job to run in minutes (1-59).<br>
Ex. - `15`.
<br>
`<cores>` - number of cores to request to run the batch job.<br>
Ex. - `4`.
<br><br>

#### Background Information
The command `wh_hydro_nlist` modifies a template of the file, `hydro.namelist`.  This file contains parameters that
are read by the model at runtime.  Among other things, it controls the hydrological routing options and their associated
parameters to be used in the run.  The command `wh_hrldas_nlist` modifies a template of the file, `namelist.hrldas`.
  Among other things, it specifies the parameters to be used in the NoahMP LSM and the period of simulation for 
the run.<br>
[Return to top](#WRF_HYDRO-R2)
<br><br><br><br>


## VII. Function Reference List
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


## VIII. Appendix
* <sup><a name="1">1</a></sup> [Github: NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [Github: NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
* <sup><a name="3">3</a></sup> [WRF-Hydro V5 Technical Description](https://github.com/LEAF-BoiseState/WRF_HYDRO-R2/blob/master/supplements/WRF-HydroV5TechnicalDescription_update512019_0.pdf)
* [NCAR RAL: WRF-Hydro Home Page](https://ral.ucar.edu/projects/wrf_hydro/overview)
* [NOAA OWP: National Water Model](https://water.noaa.gov/about/nwm)
<br>

[Return to top](#WRF_HYDRO-R2)
