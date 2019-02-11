# PlotMultiNetCDF. 
# Usage: create timeseries graphs of radiation, soil moisture, and SWE 
#        from WRFHydro output files. The script takes advantage of the 
#        'GetMultiNcdf' function from rwrfhydro which makes reading multiple
#        .nc files convenient 
#
# Requires the 'ncdf4' and 'doMC' libraries to be installed in addition to 
# rwrfhydro. 
#
#
library("rwrfhydro")
library("doMC")

# path to dataset
dataPath <- '/home/wrudisill/WRF_HYDRO-R2/example_case/Gridded'

# files lists
lsmFiles <- list.files(path=dataPath, pattern='LDASOUT_DOMAIN', full.names=TRUE)
hydroFiles <- list.files(path=dataPath, pattern='HYDRO_RST', full.names=TRUE)
flList <- list(lsm=lsmFiles, hydro=hydroFiles)

# variable list 
lsmVars   <- list(TRAD='TRAD', SWE='SNEQV')
hydroVars <- list(streamflow='qlink1', smc1='sh2ox1', smc2='sh2ox2', smc3='sh2ox3', smc4='sh2ox4')
varList <- list(lsm=lsmVars, hydro=hydroVars)

# function to apply 
basSum = function(var) sum(var) 
basMax = function(var) max(var) 

# indices to read; this step is very confusing and not well documented
# still trying to decipher what is going on here  
lsmInds   <- list(TRAD=list(start=c(1,1,1), end=c(3,2,1), stat='basSum'),
                  SNEQV=list(start=c(1,1,1), end=c(3,2,1), stat='basMax'))

hydroInds <- list(qlink1=1,
                  smc1=list(start=c(1,1), end=c(2,2), stat='basSum'),
                  smc2=list(start=c(1,1), end=c(2,2), stat='basSum'),
                  smc3=list(start=c(1,1), end=c(2,2), stat='basSum'),
                  smc4=list(start=c(1,1), end=c(2,2), stat='basSum') )

indList <- list(lsm=lsmInds, hydro=hydroInds)           # list of indices to pass into GetMuliNcdf
registerDoMC(3)                                         # each file groups; pointless to be longer than your timeseries.
fileData <- GetMultiNcdf(file=flList,var=varList, ind=indList, parallel=FALSE)  # read netcdf files 

library(ggplot2)
library(scales)
ggplot(fileData, aes(x=POSIXct, y=value, color=fileGroup)) +
          geom_line() + geom_point() +
          facet_wrap(~variableGroup, scales='free_y', ncol=1) +
          scale_x_datetime(breaks = date_breaks("1 month")) + theme_bw()
