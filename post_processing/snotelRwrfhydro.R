#' ---
#' title: "Collect SNOTEL SWE from Niwot Ridge and compare directly to model output"
#' author: "Logan Karsten"
#' date: "`r Sys.Date()`"
#' output: rmarkdown::html_vignette
#' vignette: >
#'   %\VignetteIndexEntry{Collect SNOTEL SWE for Niwot Ridge and compare directly to model output}
#'   %\\VignetteEngine{knitr::rmarkdown}
#'   \usepackage[utf8]{inputenc}
#' ---
#' 
#' # Background
#' Pull SNOTEL SWE at Niwot Ridge, which is located inside the Fourmile Creek test domain. 
#' This vignette also reads in SWE from the model output using the coordinates from the
#' SNOTEL metadata. Plots comparing the data are generated for the user. 
#' 
#' # Setup 
#' Load the rwrfhydro package.
## ---- results='hide'-----------------------------------------------------
library("rwrfhydro")

#' 
#' Load ggplo2 for plotting puposes
## ---- results='hide'-----------------------------------------------------
library(ggplot2)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#              NOT WORKING CURRENTLY 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#' 
#' Establish paths to the model output and geoGrid file for the test case.
## ---- results='hide'-----------------------------------------------------
geoFile <-"/home/wrudisill/WRF_HYDRO-R2/WRF_HydroRun_WRF_forcingtc/DOMAIN/geo_em.d02.nc" 
#modelDir <- 

#' 
#' Establish the SNOTEL site of interest, which is Niwot Ridge in this case.
## ---- results='hide'-----------------------------------------------------
stationMeta <- subset(snotelMeta,site_id == 978)
print(stationMeta)
#' 
#' # Data Extraction
#' Obtain the domain I/J coordinates using the SNOTEL lat/lon and the GetGeogridIndex function contained
#' within rwrfhydro.
## ---- results='hide'-----------------------------------------------------
#snoIJ <- GetGeogridIndex(data.frame(lon=stationMeta$lon,lat=stationMeta$lat),geoFile)

#' 
#' Pull all SNOTEL observations for the given site for the 2012/2013 years.
## ---- results='hide'-----------------------------------------------------
#snoObs <- GetSnotel(stationMeta$site_id,series="Daily",startYr=2012,endYr=2013)

#' 
#' Pull modeled SWE at the SNOTEL point from the model directory. For a detailed explanation
#' on the method of model extraction, see the GetMultiNcdf vignette for further explanation.
#' Data is pulled from the pixel cell corresponding to the SNOTEL site. 
## ---- results='hide'-----------------------------------------------------
#lsmFiles <- list.files(path=modelDir,pattern='LDASOUT_DOMAIN',full.names=TRUE)
#fList <- list(lsm=lsmFiles)
#lsmVars <- list(SWE='SNEQV')
#varList <- list(lsm=lsmVars)
#lsmInds <- list(SWE=list(start=c(snoIJ$we,snoIJ$sn,1),end=c(snoIJ$we,snoIJ$sn,1),stat='mean'))
#indList <- list(lsm=lsmInds)
#fileData <- GetMultiNcdf(file=fList,var=varList,ind=indList,parallel=FALSE)

#' 
#' Next, subset observations based on the date range that is contained within the modeled data
#' frame. We will then append the subsetted obserations into the data frame in preparation
#' for plotting.  
## ------------------------------------------------------------------------
#fileData$obsSWE <- NA
#for (step in 1:length(fileData$value)){
#   modPOSIX <- fileData$POSIXct[step]
#   ind <- which(snoObs$Date == as.Date(modPOSIX))
#   if (length(ind) != 0){
#      fileData$obsSWE[step] <- snoObs$SWE_mm[ind[1]]
#   }
#}
#
#' 
#' Finally, plot the modeled values agains the observed SWE for this SNOTEL 
#' point using the ggplo2 package.
## ---- fig.width=8,fig.height=8-------------------------------------------
#plotTitle <- paste0('Fourmile Creek Modeled SWE Against Observations for: ',stationMeta$site_name[1])
#ggplot(fileData,aes(x=POSIXct,y=value,color='Simulated')) + geom_line() + 
#  geom_line(data=fileData, aes(x=POSIXct,y=obsSWE,color='Observed'),size=1.2,linetype='dashed') +
#  scale_color_manual(name='Legend',values=c('black','red')) + 
#  ggtitle(plotTitle) + xlab('Date') + ylab('SWE (mm)')
#
#' 
