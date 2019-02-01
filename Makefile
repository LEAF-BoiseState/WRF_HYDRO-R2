# WRF_HYDRO-R2 makefile
NWM_BUILD=wrf_hydro_nwm_public/trunk/NDHMS
TESTCASE_RUN_DIR=croton_NY/NWM
TESTCASE_OUTPUT=*.CHANOBS_DOMAIN1 *.CHRTOUT_DOMAIN1 *.GWOUT_DOMAIN1 *.LAKEOUT_DOMAIN1 \
                *.LDASOUT_DOMAIN1 *.LSMOUT_DOMAIN   *.RTOUT_DOMAIN1 diag_hydro.*      \
                HYDRO_RST.*_DOMAIN1 nudgingLastObs.*.nc RESTART.*_DOMAIN1             \
		whcroton.log whcroton.out whcroton.err
RM=rm -f


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



# test case
test:
	./scripts/croton_ny_setup.sh

run:
	sbatch $(TESTCASE_RUN_DIR)/submit



.PHONY: clean

# clean
clean_nwm:
	echo -e "\nCleaning build directory: $(NWM_BUILD)\n"
	sleep 1
	cd $(NWM_BUILD) && $(MAKE) clean

clean_test:
	echo -e "\nCleaning test run directory directory: $(TESTCASE_RUN_DIR)\n"
	cd $(TESTCASE_RUN_DIR) && $(RM) $(TESTCASE_OUTPUT)


clean:  clean_nwm



