# WRF_HYDRO-R2 makefile
WHSIM=/scratch/${USER}/WH_SIM
NWM_BUILD=wrf_hydro_nwm_public/trunk/NDHMS
TESTCASE_RUN_DIR=croton_NY/NWM
TESTCASE_OUTPUT=*.CHANOBS_DOMAIN1 *.CHRTOUT_DOMAIN1 *.GWOUT_DOMAIN1 *.LAKEOUT_DOMAIN1 \
                *.LDASOUT_DOMAIN1 *.LSMOUT_DOMAIN   *.RTOUT_DOMAIN1 diag_hydro.*      \
                HYDRO_RST.*_DOMAIN1 nudgingLastObs.*.nc RESTART.*_DOMAIN1             \
		whcroton.log whcroton.out whcroton.err


IDAHO_CUT_OUTS=/scratch/leaf/WRF-Hydro/cutouts
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
CP=cp -R
MKDIR=mkdir -p
ECHO=echo -e



# default
all:    sub



# XXX working -------------------------------------
echeck:
	@$(ECHO) "USER: ${USER}"
	@$(ECHO) "DOMID: $(DOMID)"
	@$(ECHO) "RUNID: $(RUNID)"


run_dir:
ifndef RUNID
	@$(ECHO) "\n\tUSAGE: make run_dir RUNID=<run_id>\n"
else
	@test ! -d $(WHSIM)_$(RUNID) || $(ECHO) "\nRun directory already exists."
	@test   -d $(WHSIM)_$(RUNID) || $(ECHO) "\nCreating run directory..."
	@test   -d $(WHSIM)_$(RUNID) || $(MKDIR) $(WHSIM)_$(RUNID)
	@$(ECHO) "\tDirectory: $(WHSIM)_$(RUNID).\n"
endif


run_exe:
	@echo "Implement me!  'run_exe <run_ID> <routing_opt>'"


run_dom:
ifndef RUNID
	@$(ECHO) "\n\tUSAGE: make run_dom RUNID=<run_id> DOMID=<dom_id>\n"
else ifndef DOMID
	@$(ECHO) "\n\tUSAGE: make run_dom RUNID=<run_id> DOMID=<dom_id>\n"
else ifeq ($(DOMID),1)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT1) - $(CUTOUT1_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT1)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "Domain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),2)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT2) - $(CUTOUT2_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT2)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "\tDomain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),3)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT3) - $(CUTOUT3_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT3)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "\tDomain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),4)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT4) - $(CUTOUT4_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT4)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "\tDomain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),5)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT5) - $(CUTOUT5_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT5)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "\tDomain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),6)
	@$(ECHO)"\n\t$(DOMID):  $(CUTOUT6) - $(CUTOUT6_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT6)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "\tDomain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),7)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT7) - $(CUTOUT7_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT7)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "Domain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
else ifeq ($(DOMID),8)
	@$(ECHO) "\n\t$(DOMID):  $(CUTOUT8) - $(CUTOUT8_DESC)"
	@$(MKDIR) $(WHSIM)_$(RUNID)/DOMAIN
	@$(CP) $(IDAHO_CUT_OUTS)/$(CUTOUT8)/* $(WHSIM)_$(RUNID)/DOMAIN
	@$(ECHO) "Domain directory has been created: $(WHSIM)_$(RUNID)/DOMAIN\n"
endif


run_frc:
ifndef RUNID
	@$(ECHO) "\n\tUSAGE: make run_frc RUNID=<run_id> INDIR=<input_dir> GEO=<geogrid_file>\n"
else ifndef INDIR
	@$(ECHO) "\n\tUSAGE: make run_frc RUNID=<run_id> INDIR=<input_dir> GEO=<geogrid_file>\n"
else ifndef GEO
	@$(ECHO) "\n\tUSAGE: make run_frc RUNID=<run_id> INDIR=<input_dir> GEO=<geogrid_file>\n"
else
	@$(ECHO) "\nmake run_frc"
	@$(ECHO) "\tRUNID=$(RUNID)"
	@$(ECHO) "\tINDIR=$(INDIR)"
	@$(ECHO) "\tGEO=$(GEO)\n"
endif



# XXX End working -------------------------------------




# submodules
sub_mod:
	git submodule init
	git submodule update



# build
build_nwm:
	./build/build_nwm_r2.sh

build:  build_nwm



# croton ny test case
setup_test_case:
	./run_scripts/croton_ny_setup.sh

run_test_case:
	sbatch $(TESTCASE_RUN_DIR)/submit


# cut-out test cases
dom_list:
	@$(ECHO) "\n\tNUM:   Gauge ID  -  Description"
	@$(ECHO) "\t----------------------------------------------------"
	@$(ECHO) "\t  1:   $(CUTOUT1)  -  $(CUTOUT1_DESC)"
	@$(ECHO) "\t  2:   $(CUTOUT2)  -  $(CUTOUT2_DESC)"
	@$(ECHO) "\t  3:   $(CUTOUT3)  -  $(CUTOUT3_DESC)"
	@$(ECHO) "\t  4:   $(CUTOUT4)  -  $(CUTOUT4_DESC)"
	@$(ECHO) "\t  5:   $(CUTOUT5)  -  $(CUTOUT5_DESC)"
	@$(ECHO) "\t  6:   $(CUTOUT6)  -  $(CUTOUT6_DESC)"
	@$(ECHO) "\t  7:   $(CUTOUT7)  -  $(CUTOUT7_DESC)"
	@$(ECHO) "\t  8:   $(CUTOUT8)  -  $(CUTOUT8_DESC)"
	@$(ECHO) "\n"


cmd_list:
	@$(ECHO) "\n\t\t* WRF_HYDRO-R2 make reference list *"
	@$(ECHO)   "\t\t===================================="
	@$(ECHO) "\t  make sub_mod                                             #  initialize and update submodules (NWM,rwrfhydro)"
	@$(ECHO) "\t  make build                                               #  builds the NoahMP/NWM-Offline executable"
	@$(ECHO) "\t  make setup_test_case                                     #  download and setup croton_NY test case"
	@$(ECHO) "\t  make run_test_case                                       #  run the croton_NY test case"
	@$(ECHO) "\t  make cmd_list                                            #  display this reference list of commands"
	@$(ECHO) "\t  make dom_list                                            #  display reference list of cut-outs with number ID's"
	@$(ECHO) "\t  make rto_list                                            #  display reference list of routing options"
	@$(ECHO) "\t  make run_dir RUNID=<run_id>                              #  creates new run directory in user scratch"
	@$(ECHO) "\t  make run_exe RUNID=<run_id> RTOID=<routing_opt_id>       #  creates executable in run directory w/ routing option"
	@$(ECHO) "\t  make run_dom RUNID=<run_id> DOMID=<dom_id>               #  creates DOMAIN directory in run directory"
	@$(ECHO) "\t  make run_frc RUNID=<run_id> INDIR=<in_dir> GEO=<geogrid> #  convert run forcing given inuput dir and geogrid file"
	@$(ECHO) "\t  make clean_test                                          #  cleans all run output from croton_NY test"
	@$(ECHO) "\t  make clean_nwm                                           #  calls the 'make clean' target in NWM build directory"
	@$(ECHO) "\n"


rto_list:
	@$(ECHO) "\n\tNUM:   Routing option  -  Description"
	@$(ECHO) "\t----------------------------------------------------"
	@$(ECHO) "\t  0:     "
	@$(ECHO) "\t  1:     "
	@$(ECHO) "\t  2:     "
	@$(ECHO) "\t  3:     "
	@$(ECHO) "\t  4:     "
	@$(ECHO) "\n"



.PHONY: clean

# clean
clean_nwm:
	$(ECHO) "\nCleaning build directory: $(NWM_BUILD)\n"
	sleep 1
	cd $(NWM_BUILD) && $(MAKE) clean

clean_test:
	$(ECHO) "\nCleaning test run directory directory: $(TESTCASE_RUN_DIR)\n"
	cd $(TESTCASE_RUN_DIR) && $(RM) $(TESTCASE_OUTPUT)


clean:  clean_nwm



