# Evaluate streamflow observations
library(dataRetrieval)
library(data.table)
library(ggplot2)
library(foreach)
library(rwrfhydro)


#~~~~~~ Download USGS streamflow to evaluate. Uses the USGS 'data retrieval' package~~~~~~
# we already know the USGS gauge IDs that match the forecast points we have modelled

gageID <- c("01374559", "01374581", "0137462010")
obsDF <- readNWISuv(siteNumbers=gageID, parameterCd="00060", startDate="2011-08-25", endDate="2011-09-03")
colnames(obsDF) <- c("agency","site_no","dateTime","streamflow_cfs","quality_flag", "time_zone")
obsDF$q_cms <- obsDF$streamflow_cfs/35.31

#find the "reference file" from the test case. This file contains the index number of the gauge (i.e. 1, 2, 3, etc)
referenceFile <- "/home/wrudisill/WRF_HYDRO-R2/example_case/Gridded/croton_frxst_pts_csv.csv"
refDF <- read.csv(referenceFile, colClasses = c("integer", "numeric", "numeric", "character", "character"))

# merge the index numer into the observation data frame 
obsDF <- merge(obsDF,  refDF[, c("FID", "Site_No")], by.x = "site_no", by.y = "Site_No")
obsDF$station <- obsDF$FID  ## adding the feature_id

#~~~~~~ Read in Model Discharge Outputs ~~~~~~# 
modelOutputPath <- "/home/wrudisill/WRF_HYDRO-R2/example_case/Gridded/frxst_pts_out.txt"
simQ <- read.csv(modelOutputPath, col.names =  c("TimeFromStart", "dateTime", "station", "longitude", "latitude", "q_cms","q_cfs", "stage"), colClasses = c("integer", "character", "character", rep("numeric", 5)), header = FALSE)


#~~~~~~ Create a ggplot of the observations versus the model simulation ~~~~~~~# 
obsDF$run <- "Observation"
simQ$run <- "Gridded Baseline"
selected_cols<-c("dateTime", "station", "q_cms","run")

# merge the observations and model data frames w/ only the most important columns
merged <- rbind(obsDF[,selected_cols], simQ[,selected_cols])

# make sure that the station number is numeric, not a character
merged$station <- as.numeric(merged$station)

# plot the data
ggplot(data = merged) + geom_line(aes(dateTime, q_cms, color=run)) + facet_wrap(~station, ncol = 1)
