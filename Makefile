# WRF_HYDRO-R2 makefile
NWM_BUILD=wrf_hydro_nwm_public/trunk/NDHMS
TESTCASE_RUN_DIR=croton_NY/NWM
TESTCASE_OUTPUT=*.CHANOBS_DOMAIN1 *.CHRTOUT_DOMAIN1 *.GWOUT_DOMAIN1 *.LAKEOUT_DOMAIN1 \
                *.LDASOUT_DOMAIN1 *.LSMOUT_DOMAIN   *.RTOUT_DOMAIN1 diag_hydro.*      \
                HYDRO_RST.*_DOMAIN1 nudgingLastObs.*.nc RESTART.*_DOMAIN1             \
		whcroton.log whcroton.out whcroton.err


IDAHO_CUT_OUTS=/scratch/leaf/share/WRF_hydro_subsets_201810
CUTOUT1=13139510
CUTOUT1_DESC="Big Wood River at Hailey ID"
CUTOUT2=13168500
CUTOUT2_DESC="Bruneau River near Hot Springs ID"
CUTOUT3=13185000
CUTOUT3_DESC="Boise River near Twin Springs ID"
CUTOUT4=13186000
CUTOUT4_DESC="SF Boise River near Featherville ID"
CUTOUT5=13235000
CUTOUT5_DESC="SF Payette River at Lowman ID"
CUTOUT6=13237920
CUTOUT6_DESC="MF Payette River near Crouch ID"
CUTOUT7=13258500
CUTOUT7_DESC="Weiser River near Cambridge ID"
CUTOUT8=13316500
CUTOUT8_DESC="Little Salmon River at Riggins ID"

RM=rm -f
MKDIR=mkdir -p
CP=cp -R

# default
all:    sub


# submodules
sub:
	git submodule init
	git submodule update



# build
build_nwm:
	./build/build_nwm_r2.sh

build:  build_nwm



# croton ny test case
test:
	./run_scripts/croton_ny_setup.sh

run:
	sbatch $(TESTCASE_RUN_DIR)/submit


# cut-out test cases
list_cutout:
	@echo -e "\n\tNUM:   Gauge ID  -  Description"
	@echo -e "\t----------------------------------------------------"
	@echo -e "\t  1:   13139510  -  Big Wood River at Hailey ID"
	@echo -e "\t  2:   13168500  -  Bruneau River near Hot Springs ID"
	@echo -e "\t  3:   13185000  -  Boise River near Twin Springs ID"
	@echo -e "\t  4:   13186000  -  SF Boise River near Featherville ID"
	@echo -e "\t  5:   13235000  -  SF Payette River at Lowman ID"
	@echo -e "\t  6:   13237920  -  MF Payette River near Crouch ID"
	@echo -e "\t  7:   13258500  -  Weiser River near Cambridge ID"
	@echo -e "\t  8:   13316500  -  Little Salmon River at Riggins ID\n\n"

copy_cutout:
ifndef NUM
	@echo -e "\n\tNo cut-out ID provided."
	@echo -e "\tTry 'make list_cutouts' for listing of cut-out IDs.\n"
else ifeq ($(NUM),1)
	@echo -e "\n\t$(NUM):  $(CUTOUT1) - $(CUTOUT1_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT1)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT1)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT1)/* run_dir_gid$(CUTOUT1)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT1)/\n"
else ifeq ($(NUM),2)
	@echo -e "\t$(NUM):  $(CUTOUT2) - $(CUTOUT2_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT2)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT2)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT2)/* run_dir_gid$(CUTOUT2)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT2)/\n"
else ifeq ($(NUM),3)
	@echo -e "\n\t$(NUM):  $(CUTOUT3) - $(CUTOUT3_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT3)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT3)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT3)/* run_dir_gid$(CUTOUT3)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT3)/\n"
else ifeq ($(NUM),4)
	@echo -e "\n\t$(NUM):  $(CUTOUT4) - $(CUTOUT4_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT4)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT4)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT4)/* run_dir_gid$(CUTOUT4)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT4)/\n"
else ifeq ($(NUM),5)
	@echo -e "\n\t$(NUM):  $(CUTOUT5) - $(CUTOUT5_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT5)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT5)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT5)/* run_dir_gid$(CUTOUT5)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT5)/\n"
else ifeq ($(NUM),6)
	@echo -e"\n\t$(NUM):  $(CUTOUT6) - $(CUTOUT6_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT6)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT6)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT6)/* run_dir_gid$(CUTOUT6)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT6)/\n"
else ifeq ($(NUM),7)
	@echo -e "\n\t$(NUM):  $(CUTOUT7) - $(CUTOUT7_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT7)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT7)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT7)/* run_dir_gid$(CUTOUT7)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT7)/\n"
else ifeq ($(NUM),8)
	@echo -e "\n\t$(NUM):  $(CUTOUT8) - $(CUTOUT8_DESC)\n"
	@$(MKDIR) run_dir_gid$(CUTOUT8)/DOMAIN
	@$(CP) $(NWM_BUILD)/Run/* run_dir_gid$(CUTOUT8)
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT8)/* run_dir_gid$(CUTOUT8)/DOMAIN
	@echo -e "\tRun directory has been created:  ./run_dir_gid$(CUTOUT8)/\n"
endif



help:
	@echo -e "\n\t\t* WRF_HYDRO-R2 make reference list *"
	@echo -e   "\t\t===================================="
	@echo -e "\t  make help                  #  display this reference list"
	@echo -e "\t  make sub                   #  initialize and update submodules (NWM,rwrfhydro)"
	@echo -e "\t  make build                 #  builds the NoahMP/NWM-Offline executable"
	@echo -e "\t  make test                  #  download and setup croton_NY test case"
	@echo -e "\t  make run                   #  run the croton_NY test case"
	@echo -e "\t  make list_cutout           #  display reference list of cut-outs with number ID's"
	@echo -e "\t  make copy_cutout NUM=<num> #  create a copy of cutout directory for number ID <num>"
	@echo -e "\t  make clean_test            #  cleans all run output from croton_NY test"
	@echo -e "\t  make clean_nwm             #  calls the 'make clean' target in NWM build directory"
	@echo -e "\n"






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



