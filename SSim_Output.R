library(raster)
library(rsyncrosim)

setwd("C:/Users/merri/Documents/CDL Research/RWork/WNFProject/SSimModels")

myLibrary <- ssimLibrary(name = "RScript.ssim", #CHANGE THIS
                         overwrite = F)
project(myLibrary) #used to check that you're in the right directory. 
#if the library has no project, you have accidentally created a new library. go back and check your wd

myProject <- project(myLibrary, project = 1) #odds are you will be working from project 1, change if not
scenario(myProject, results = TRUE) #pick the ID of the run result you want
myScenario <- scenario(myProject, scenario = 5) #Change ID in 'scenario ='

myRaster <- datasheetRaster(myScenario, "OutputSpatialState", timestep = 2030 #CHANGE TIMESTEP
) #if timestep is not included it retrieves all rasters

plot(myRaster)