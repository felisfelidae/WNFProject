library(rsyncrosim)
library(ggplot2)

myLibrary <- ssimLibrary("OhioWNFFirstStrikes.ssim", overwrite = F)

project(myLibrary)

wnfProject <- project(myLibrary, project = "Definitions")
wnfProject

datasheet(wnfProject, summary = T)

scenario(wnfProject, summary = T)
  
runResults <- run(wnfProject, scenario = c("ACDOW BpS 2020-2050", "ACDOW, percentages reset"), jobs = 6, summary = T)

runResults

bpsScenario <- scenario(myLibrary, "ACDOW BpS 2020-2050")
modernScenario <- scenario(myLibrary, "ACDOW, percentages reset")

resultIDBpS <- subset(runResults, 
                            parentID == scenarioId(bpsScenario))$scenarioId
resultPReset <- subset(runResults, 
                      parentID == scenarioId(modernScenario))$scenarioId


outputStratumState <- datasheet(wnfProject,
                                scenario = c(resultIDBpS, resultPReset),
                                name = "stsim_OutputStratumState")

outputSum <- aggregate(outputStratumState['Amount'], 
                       by=outputStratumState[c("Iteration", "Timestep", "StateLabelXID", )], sum)
outputMean <- aggregate(outputSum["Amount"], by=outputSum[c("Timestep", "StateLabelXID")], mean)

early1 <- subset(outputMean, StateLabelXID=="Early1")

xAxis <- early1$Timestep
yAxis <- early1$Amount

ggplot(data = early1, aes(x = xAxis, y =yAxis)) +
  geom_smooth()
