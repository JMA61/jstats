
## ============================================================
## 7036CCJ JeffsStatTools Installation and Update Instructions
## ============================================================

## NOTE: During install or update you may see a prompt like:
##   "Which would you like to update? 1: All  2: CRAN only  3: None ..."
## Select 3 (None).

## You can ignore any other warning messages as long as
## you see DONE (JeffsStatTools) and the version number updates correctly.

## -- INITIAL INSTALL (run once only) --------------------------
install.packages("remotes")
remotes::install_github("JMA61/JeffsStatTools")
library(JeffsStatTools)

## -----------------------------------------------

## -- TO UPDATE -------------------------------------------------

## !! IMPORTANT !! ----------------------------------------------
## Save all open R scripts before proceeding (Ctrl+S / Cmd+S)
## --------------------------------------------------------------

if ("JeffsStatTools" %in% (.packages())) {
  detach("package:JeffsStatTools", unload = TRUE)
}
remotes::install_github("JMA61/JeffsStatTools", build = TRUE)

## -- AFTER THE INSTALL COMPLETES -------------------------------

##   1. Restart your R session (Session menu -> Restart R)
##   2. You should get a message at the bottom of your console
##      that JeffsStatTools is up to date.
##   3. You can also confirm JeffsStatTools is installed by running:
packageVersion("JeffsStatTools")
##   4. And ensure that JeffsStatTools is loaded by running:
## This line should also go into your .Rprofile file so that you don't have to manually run it for each new session
library(JeffsStatTools)

## -- EXPLORE THE FUNCTIONS -------------------------------------
## Run each line below one at a time to read the help page for
## each function before using it. Pay attention to the examples
## at the bottom of each help page -- you can run them directly.

?jalpha   # Cronbach's alpha reliability analysis
?jaov     # One-way ANOVA
?jchisq   # Chi-square test and cross-tabulation
?jcorr    # Bivariate correlation matrix
?jdesc    # Descriptive statistics
?jfreq    # Frequency tables
?jlm      # Linear regression
?jscreen  # Data screening overview
?jt       # T-test (independent or paired)
