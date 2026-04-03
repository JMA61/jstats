


SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")

SampleData$TotalCrime <- SampleData$Drugs + SampleData$Graffiti + SampleData$Smoking #Remember, you need 6 variables for the Assessments

jdesc(SampleData,TotalCrime) # run descriptives on the new variable.


jdesc(SampleData,TotalCrime, by = Gender)
jt(TotalCrime ~ Gender, data = SampleData)
