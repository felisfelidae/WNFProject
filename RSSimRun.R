library(tidyverse)
library(sf)
library(raster)
library(dplyr)
library(foreign)
library(rsyncrosim)


#Myles Waalima's raster-creating code. 
setwd("C:/Users/merri/Documents/CDL Research/RWork/WNFProject")
#Make sure your working directory has the /DATA file and an empty /OUTPUTs in it or change those folders to suit

# read your area of interest shapefile and reproject to LF
shp <- st_read("./DATA/ironton.shp") %>% ## this is the line right here you need to change!!
  st_transform(crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs") %>%
  st_union() %>%
  st_sf()

if (file.exists("./DATA/US_200BPS/us_200bps/hdr.adf") == T) {
  bps <- raster("./DATA/US_200BPS/us_200bps/hdr.adf") %>%
    crop(shp) %>%
    mask(shp)
  writeRaster(bps, "./OUTPUTS/bps_aoi_crop.tif", overwrite = T, format="GTiff", options=c('TFW=YES'), datatype = "INT2S")
  
  bps_x <- bps %>%
    raster::extract(shp) %>%
    unlist() %>%
    table(dnn = "ID") %>%
    as.data.frame() %>%
    arrange(desc(Freq)) %>%
    mutate_all(as.character) %>%
    mutate_all(as.integer) %>%
    left_join(levels(bps)[[1]], by = "ID") %>%
    transmute(ID = ID,
              COUNT = Freq,
              BPS_NAME = BPS_NAME %>%
                as.character() %>%
                as.factor(),
              # GROUPNAME = GROUPNAME %>%
              #   as.character() %>%
              #   as.factor(),
              GROUPVEG = GROUPVEG,
              acres = (Freq * 900 / 4046.86),
              hectare = (Freq * 900 / 10000),
              rel_percent = (Freq / sum(Freq)) * 100)
  write.csv(bps_x, "./OUTPUTS/bps_aoi_attributes.csv")
  write.dbf(bps_x, "./OUTPUTS/bps_aoi_cropINT.tif.vat.dbf")
  print("BPS raster was cropped and exported as bps_aoi_crop.tif in OUTPUTS folder", quote = F)
  print("BPS data frame was created and exported as bps_aoi_attributes.csv in OUTPUTS folder", quote = F)
} else { message("'./DATA/US_200BPS/us_200bps/hdr.adf' does not exist", quote = F) }

if (file.exists("./DATA/US_200SCLASS/us_200sclass/hdr.adf") == T) {
  sclass <- raster("./DATA/US_200SCLASS/us_200sclass/hdr.adf") %>%
    crop(shp) %>%
    mask(shp)
  writeRaster(sclass, "./OUTPUTS/sclass_aoi_crop.tif", overwrite = T, format="GTiff", options=c('TFW=YES'), datatype = "INT2S")
  
  sclass_x <- sclass %>%
    raster::extract(shp) %>%
    unlist() %>%
    table(dnn = "ID") %>%
    as.data.frame() %>%
    arrange(desc(Freq)) %>%
    mutate_all(as.character) %>%
    mutate_all(as.integer) %>%
    left_join(levels(sclass)[[1]], by = "ID") %>%
    transmute(ID = ID,
              COUNT = Freq,
              LABEL = LABEL,
              acres = (Freq * 900 / 4046.86), # Freq is count of 30x30m or 900m^2 pixels, convert to acres
              hectare = (Freq * 900 / 10000),
              rel_percent = (Freq / sum(Freq)) * 100)
  write.csv(sclass_x, "./OUTPUTS/sclass_aoi_attributes.csv")
  write.dbf(sclass_x, "./OUTPUTS/sclass_aoi_cropINT.tif.vat.dbf")
  print("SCLASS raster was cropped and exported as sclass_aoi_crop.tif in OUTPUTS folder", quote = F)
  print("SCLASS data frame was created and exported as sclass_aoi_attributes.csv in OUTPUTS folder", quote = F)
} else { message("'./DATA/US_140SCLASS/us_140sclass/hdr.adf' does not exist in DATA folder", quote = F) }  

stratumTif <- "./OUTPUTS/bps_aoi_crop.tif"
stratumTif <- normalizePath(stratumTif)
sclassTif <- "./OUTPUTS/sclass_aoi_crop.tif"
sclassTif <- normalizePath(sclassTif)

rStratum <- raster(stratumTif)
rSclass <-raster(sclassTif)

setwd("./SSimModels") #CHANGE THIS depending on where you keep your syncrosim models

myLibrary <- ssimLibrary(name = "The Other ACDOW.ssim", #CHANGE THIS
                         package = "landfirevegmodels", overwrite = F)
project(myLibrary)

myProject = project(myLibrary, project = "Definitions")
myProject

#CHANGE SOURCE SCENARIO AND SCENARIO NAME
myScenario <- scenario(myProject, scenario = "New Spatial Run", sourceScenario = "Modern Percentages - no fire")

sheetName <- "stsim_InitialConditionsSpatial"
sheetData <- list(StratumFileName = stratumTif, 
                  StateClassFileName = sclassTif)
saveDatasheet(myScenario, sheetData, sheetName)

#sets stratum ID to whatever has the most cells; can be manually changed by manipulating maxID value
rastFreq <- data.frame(freq(rStratum))
maxID <- which.max(rastFreq$count)
maxID <- rastFreq[maxID,]$value

sheetData <- datasheet(myProject, "stsim_Stratum")
sheetData$ID <- maxID #CAN BE MANUALLY CHANGED
saveDatasheet(myProject, sheetData, "stsim_Stratum")

sheetData<-datasheet(myScenario, "landfirevegmodels_SuccessionClassDescription")
LFVMDesc <- data.frame(sheetData)
sheetData<- datasheet(myProject, "stsim_StateClass")

for (i in 1: nrow(LFVMDesc)){
  for (j in 1:nrow(sheetData)) {
    if (LFVMDesc[i,]$StateClassID == sheetData[j,]$Name){
      sheetData[j,]$ID = i
    }
  }
}

sheetName <- "stsim_RunControl"
sheetData <- data.frame(MaximumIteration = 1, #change this to suit your needs
                        MinimumTimestep = 2020, #change this to suit your needs
                        MaximumTimestep = 2050, #change this to suit your needs
                        isSpatial = TRUE)
saveDatasheet(myScenario, sheetData, sheetName)

sheetData <- data.frame(
  SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
  SummaryOutputTR = T, SummaryOutputTRTimesteps = 1
)
saveDatasheet(myScenario, sheetData, "stsim_OutputOptions")
sheetData <- data.frame(
  RasterOutputSC = T, RasterOutputSCTimesteps = 1,
  RasterOutputTR = T, RasterOutputTRTimesteps = 1,
  RasterOutputAge = T, RasterOutputAgeTimesteps = 1
)
saveDatasheet(myScenario, sheetData, "stsim_OutputOptionsSpatial")


#NOT WORKING YET
resultSummary <- run(myProject, scenario = c("New Spatial Run"), #change
                     jobs = 1, #change
                     summary = TRUE)

runSummary <- subset(resultSummary, parentID == scenarioId(myScenario))$scenarioId
outputStratumState <- datasheet(myProject, scenario = c(runSummary), name = "stsim_OutputStratumState")

myRastersTimestep5 <- datasheetRaster(myProject, 
                                      scenario = runSummary, 
                                      "stsim_OutputSpatialState", 
                                      timestep = 5)
