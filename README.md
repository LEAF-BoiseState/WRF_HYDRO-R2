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
├── Makefile                      # top level makefile
├── README.md                    
├── scripts                      
│   ├── build_nwm_r2.sh           # build script
│   └── env_nwm_r2.sh             # environment script
└── wrf_hydro_nwm_public/         # nwm sub repo
```

## Build
```bash            
git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repo
cd WRF_HYDRO-R2                                              # go into repo
source scripts/env_nwm_r2.sh                                 # source r2 environment
make sub                                                     # init/update submodules
make build                                                   # build NWM-offline exe
```
If you received a 'BUILD UNSUCCESSFUL' message from the `make build` step (assuming the preceding steps were successful), try these
steps to troubleshoot.  First, assess what went wrong from looking at the build log file, the path will be given just below the
UNSUCCESSFUL message.  Next, make any necessary changes to address the problem.  Lastly, clean out the build directory and re-issue
the build command, e.g. (assuming you are back in the top-level dir, WRF_HYDRO-R2):
```bash
make clean                                                   # calls make clean in build dir
make build                                                   # build NWM-offline exe
```
A successful build should display a 'BUILD SUCCESSFUL!!!' message.
<br>

                                                             
## Make Target Reference
```bash                        
make                    # default, calls targets: sub, r2_env
make sub                # initializes and updates submodule NWM
make build              # builds the NoahMP/NWM-Offline exe
make clean              # calls the 'make clean' target in NWM build dir
```
                                                                             
## Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)          
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)
