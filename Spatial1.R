library(rsyncrosim)
library(raster)

stratumTif <- "C:/Users/merri/Documents/CDL Research/SyncroSim in R/OUTPUTS/bps_aoi_crop.tif"
sclassTif <- "C:/Users/merri/Documents/CDL Research/SyncroSim in R/OUTPUTS/sclass_aoi_crop.tif"

rStratum <- raster(stratumTif)
rSclass <-raster(sclassTif)

myLibrary <- ssimLibrary(name = "The Other ACDOW.ssim", package = "landfirevegmodels", overwrite = F)
project(myLibrary)

myProject = project(myLibrary, project = "Definitions")
myProject

datasheet(myProject, summary = T)
scenario(myProject, summary = T)

myScenario = scenario(myProject, scenario = "Modern Percentages")
myScenario

runResults <- run(myProject, myScenario, jobs = 6, summary = T)

sheetName <- "stsim_InitialConditionsSpatial"
sheetData <- list(StratumFileName = stratumTif, 
                  StateClassFileName = sclassTif)
saveDatasheet(myScenario, sheetData, sheetName)

rStratumTest <- datasheetRaster(myScenario, sheetName, "StratumFileName")
rSclassTest <- datasheetRaster(myScenario, sheetName, "StateClassFileName")

plot(rStratumTest)
plot(rSclassTest)
