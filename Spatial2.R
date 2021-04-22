library(rsyncrosim)
library(raster)
library(this.path)

getwd()

list.files()
myLibrary <- ssimLibrary("The Other ACDOW", package = "landfirevegmodels")

project(myLibrary)
myProject <- project(myLibrary, project="Definitions")
myProject

datasheet(myProject, summary=TRUE)

sheetData <- datasheet(myProject, name="stsim_Terminology")
str(sheetData)

sheetData$AmountUnits <- "Acres"
sheetData$StateLabelX <- "Forest Type"

saveDatasheet(myProject, sheetData, "stsim_Terminology")

sheetData <- datasheet(myProject, "stsim_Stratum", empty = TRUE)




stratumTif <- "C:/Users/merri/Documents/CDL Research/SyncroSim in R/OUTPUTS/bps_aoi_crop.tif"
sclassTif <- "C:/Users/merri/Documents/CDL Research/SyncroSim in R/OUTPUTS/sclass_aoi_crop.tif"

rStratum <- raster(stratumTif)
rSclass <-raster(sclassTif)

