
########## NEW UPDATE INSTRUCTIONS #################

Remember to change version number below, and in Description file
...can also update what was changed in this version in the git commit -m code below

# 1) Run this code IN THE CONSOLE or from here to rebuild the docs and run a check
devtools::document()  # this updates the documentation - including creating help files for ?jt for example.
devtools::check()     # this is an optional more thorough check. there will be some ERROR that has to quarto - ignore.


# 2) Run this code IN THE TERMINAL - note the change to the version number:

# To Commit the new version:
git add -A
git commit -m "Round p values in jt() and jaov(), bump version to 0.3.2"

# To Push/Upload to GitHub
git push

# To create the version tag
git tag -a v0.3.2 -m "Version 0.3.2"
git push --tags

# Verity that the tag exists:
git tag



### Students (and me) will install the latest version with:
remotes::install_github("JMA61/JeffsStatTools")

# If I wanted to install immediately on my local machine, I could add:
#   devtools::install()
# right after  devtools::check()

### To load the functions into the current session use
devtools::load_all()

### Necessary testing code ###
SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")
library(JeffsStatTools)

jdesc(SampleData, Gender)
jdesc(SampleData, RlshpStatus)

jdesc(SampleData, Environment1)
jdesc(SampleData, Environment1, labels = FALSE)


x <- c(10, 20, 30, 40, 50)
jdesc(x)

jfreq(x)


GenderF <- SampleData$Gender



jfreq(SampleData, Gender)
jfreq(GenderF)


jt(JuvenileDelinquency ~ Gender, data=SampleData)
jt(JuvenileDelinquency ~ Gender, data=SampleData,welch = TRUE)
jt(JuvenileDelinquency ~ Gender, data=SampleData, full = TRUE)

jaov(JuvenileDelinquency ~ RlshpStatus, data=SampleData)
jaov(JuvenileDelinquency ~ RlshpStatus, data=SampleData,welch = TRUE)
jaov(JuvenileDelinquency ~ RlshpStatus, data=SampleData,welch = TRUE, ci=TRUE)
jaov(JuvenileDelinquency ~ RlshpStatus, data=SampleData, full = TRUE)

labelled::var_label(SampleData$RlshpStatus)


SampleData$Conservative3Recode <- case_when(
  SampleData$Conservative3 == 1 ~ 5,
  SampleData$Conservative3 == 2 ~ 4,
  SampleData$Conservative3 == 3 ~ 3,
  SampleData$Conservative3 == 4 ~ 2,
  SampleData$Conservative3 == 5 ~ 1
)

selected_vars <- SampleData[, c("Conservative1", "Conservative2", "Conservative3Recode", "Conservative4", "Conservative5")]

library(psych)

# Calculate Cronbach's alpha
alpha_result <- alpha(selected_vars)
print(alpha_result)

jalpha(SampleData, Conservative1, Conservative2, Conservative3Recode,
       Conservative4, Conservative5)

jalpha(SampleData, Conservative1, Conservative2, Conservative3Recode,
       Conservative4, Conservative5, Conservative6)

jalpha(SampleData, Conservative1, Conservative2, Conservative3,
       Conservative4, Conservative5, Conservative6)

jalpha(SampleData, Conservative1, Conservative2, Conservative3Recode,
       Conservative4, Conservative5)


jscreen(SampleData)

jchisq(RlshpStatus ~ Gender, data = SampleData)
jchisq(RlshpStatus ~ Gender, data = SampleData, expected = TRUE, col.pct = TRUE)

?jdesc
?jt
?jcorr
?jaov
?jscreen
?jlm
?jalpha


jaov(mpg ~ cyl, data = mtcars)

mtcars$cyl_f <- factor(mtcars$cyl)

jaov(mpg ~ cyl_f, data = mtcars)

jaov(mpg ~ cyl, data = mtcars)

jt(mpg ~ am, data = mtcars)
jt(mpg ~ am, data = mtcars, welch = TRUE)
jt(mpg ~ am, data = mtcars, full = TRUE)

