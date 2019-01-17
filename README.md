# WRF_HYDRO-R2
*Wrapper to automate build + run + vis for WRF-Hydro v5 / NWM on R2*
<br>
<br>

## Objective
This container uses the NCAR NWM<sup>[1](#1)</sup> repo 
and rwrfhydro<sup>[2](#2)</sup> repo as submodules.
<br>

## Manifest
```bash
WRF_HYDRO-R2/
├── LICENSE
├── Makefile
├── README.md
└── wrf_hydro_nwm_public/       # nwm submodule
```
<br>

## Build
see `make build` below.
<br>

## Commands
```bash
$ git clone https://github.com/LEAF-BoiseState/WRF_HYDRO-R2    # clone repo
$ cd WRF_HYDRO-R2                                              # go into repo
$ make sub                                                     # init/update submodule
```
<br>

## Links
* <sup><a name="1">1</a></sup> [NCAR National Water Model](https://github.com/NCAR/wrf_hydro_nwm_public)
* <sup><a name="2">2</a></sup> [NCAR rwrfhydro](https://github.com/NCAR/rwrfhydro)

