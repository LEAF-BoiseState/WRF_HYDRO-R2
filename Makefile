# WRF_HYDRO-R2 makefile
MODS=mod_loads.sh


all:  sub



sub:
	git submodule init
	git submodule update


.PHONY: clean


clean:
	echo "clean not implemented"


