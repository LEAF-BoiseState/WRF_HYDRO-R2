# WRF_HYDRO-R2 makefile
NWM_BUILD=wrf_hydro_nwm_public/trunk/NDHMS



# default
all:    sub



# submodules
sub:
	git submodule init
	git submodule update



# build
build_nwm:
	./scripts/build_nwm_r2.sh

build:  build_nwm




.PHONY: clean

# clean
clean_nwm:
	echo -e "\nCleaning build directory: $(NWM_BUILD)\n"
	sleep 1
	cd $(NWM_BUILD) && $(MAKE) clean

clean:  clean_nwm



