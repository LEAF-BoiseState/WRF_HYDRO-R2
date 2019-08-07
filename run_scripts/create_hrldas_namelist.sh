#
# create_hrldas_namelist.sh - create namelist.hrldas with simulation period, etc.
# matt masarik 
# 6 aug 2019 
# 

# PARAMETERS
FORCING_TYPE=3                            # forcing input type: 3= WRF output, 4= Idealized
FORCING_TIMESTEP=3600                     # forcing time step [seconds]
OUTPUT_TIMESTEP=3600                      # output time step  [seconds]

# PARAMETERS - NOAHMP
NOAH_TIMESTEP=3600                        # NoahMP time step  [seconds]
DYNAMIC_VEG_OPTION=4                      # dynamic vegetation
CANOPY_STOMATAL_RESISTANCE_OPTION=1       # canopy stomatal resistance
BTR_OPTION=1                              #
RUNOFF_OPTION=3                           # runoff
SURFACE_DRAG_OPTION=1                     # surface drag
FROZEN_SOIL_OPTION=1                      # frozen soil
SUPERCOOLED_WATER_OPTION=1                # supercooled water
RADIATIVE_TRANSFER_OPTION=3               # radiative transfer
SNOW_ALBEDO_OPTION=2                      # snow albedo
PCP_PARTITION_OPTION=1                    # 
TBOT_OPTION=2                             # 
TEMP_TIME_SCHEME_OPTION=3                 # glacier
GLACIER_OPTION=2                          # surface resistance
SURFACE_RESISTANCE_OPTION=4


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
sed -i'' "s/forctyp/$FORCING_TYPE/g"              $namelist_hrldas_path
sed -i'' "s/forcingtimestep/$FORCING_TIMESTEP/g"  $namelist_hrldas_path
sed -i'' "s/outputtimestep/$OUTPUT_TIMESTEP/g"    $namelist_hrldas_path
sed -i'' "s/noahtimestep/$NOAH_TIMESTEP/g"                                        $namelist_hrldas_path
sed -i'' "s/dynamicvegoption/$DYNAMIC_VEG_OPTION/g"                               $namelist_hrldas_path
sed -i'' "s/canopystomatalresistanceoption/$CANOPY_STOMATAL_RESISTANCE_OPTION/g"  $namelist_hrldas_path
sed -i'' "s/btroption/$BTR_OPTION/g"                                              $namelist_hrldas_path
sed -i'' "s/runoffoption/$RUNOFF_OPTION/g"                                        $namelist_hrldas_path
sed -i'' "s/surfacedragoption/$SURFACE_DRAG_OPTION/g"                             $namelist_hrldas_path
sed -i'' "s/frozensoiloption/$FROZEN_SOIL_OPTION/g"                               $namelist_hrldas_path
sed -i'' "s/supercooledwateroption/$SUPERCOOLED_WATER_OPTION/g"                   $namelist_hrldas_path
sed -i'' "s/radiativetransferoption/$RADIATIVE_TRANSFER_OPTION/g"                 $namelist_hrldas_path
sed -i'' "s/snowalbedooption/$SNOW_ALBEDO_OPTION/g"                               $namelist_hrldas_path
sed -i'' "s/pcppartitionoption/$PCP_PARTITION_OPTION/g"                           $namelist_hrldas_path
sed -i'' "s/tbotoption/$TBOT_OPTION/g"                                            $namelist_hrldas_path
sed -i'' "s/temptimeschemeoption/$TEMP_TIME_SCHEME_OPTION/g"                      $namelist_hrldas_path
sed -i'' "s/glacieroption/$GLACIER_OPTION/g"                                      $namelist_hrldas_path
sed -i'' "s/surfaceresistanceoption/$SURFACE_RESISTANCE_OPTION/g"                 $namelist_hrldas_path


exit
