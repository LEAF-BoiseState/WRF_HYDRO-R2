#
# create_hrldas_namelist.sh - create namelist.hrldas with simulation period, etc.
# matt masarik 
# 6 aug 2019 
# 

# PARAMETERS - DEFAULT / USER
FORCING_TYPE=3          # 3 = WRF output
                        # 4 = Iidealized
FORCING_TIMESTEP=3600   # [seconds]
NOAH_TIMESTEP=3600      # [seconds]
OUTPUT_TIMESTEP=3600    # [seconds]

# USER INPUT
if [ $# -ne 6 ]; then
    echo -e "\n\tUSAGE: $(basename $0) <namelist_hrldas> <yyyy> <mm> <dd> <hh> <sim_hours>\n"
    exit 1
fi
namelist_hrldas_path="$1"
year="$2"
mn="$3"
dy="$4"
hr="$5"
sim_hours="$6"


# ----------------------------------------------------------------------------- *
#                     MAIN - CREATE NAMELIST.HRLDAS
# ----------------------------------------------------------------------------- *
sed -i'' "s/startyear/$year/g"                    $namelist_hrldas_path
sed -i'' "s/startmonth/$mn/g"                     $namelist_hrldas_path
sed -i'' "s/startday/$dy/g"                       $namelist_hrldas_path
sed -i'' "s/starthour/$hr/g"                      $namelist_hrldas_path
sed -i'' "s/simhours/$sim_hours/g"                $namelist_hrldas_path
sed -i'' "s/forcingtimestep/$FORCING_TIMESTEP/g"  $namelist_hrldas_path
sed -i'' "s/noahtimestep/$NOAH_TIMESTEP/g"        $namelist_hrldas_path
sed -i'' "s/outputtimestep/$OUTPUT_TIMESTEP/g"    $namelist_hrldas_path
sed -i'' "s/forctyp/$FORCING_TYPE/g"              $namelist_hrldas_path

exit
