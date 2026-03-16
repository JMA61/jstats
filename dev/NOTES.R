

### I started by creating this package project using this code from a different R Project ###
#usethis::create_package("E:/00 R Projects/JeffsStatTools")

### STEP 1 ###
### These three packages need installed ###
#install.packages(c("devtools", "roxygen2", "usethis"))

###You do not have to run library(devtools) every session — you can call functions with devtools::###
# Example: devtools::document()  - this is cleaner in package development

### STEP 2 ###
# Add the desired custom functions to the R/ Folder
# Copy/Paste all functions into a single R script file with this format:
# Note - the hash tags with the single quote after them, below are part of what needs to be copied
# to the top of each function #

### NOTE That I've changed the code below based upon what Chat told me ###
### Also chat was used to specifically/explicitly mention the necessary packages before each
### function was copied.



  #' Brief title of function
  #'
  #' Longer description of what it does.
  #'
  #' @param x Description of x
  #' @param y Description of y
  #' @return What the function returns
  #' @export
  my_function <- function(x, y) {
    x + y
  }

### STEP 3 ###
#  Run the following in the console to tell the project what other packages these functions rely upon.

#  These are necessary for the jdesc

  usethis::use_package("rlang")
  usethis::use_package("purrr")
  usethis::use_package("dplyr")
  usethis::use_package("knitr")
  usethis::use_package("vctrs")

### STEP 4 ###
# Create License file by running this in the console
  usethis::use_mit_license("Jeff Ackerman")
# that will create a license and license.md file in the directory

### STEP 5 ###
#  Run this in the console
  devtools::document()

### STEP 6 ###
# Run this to check everything
  devtools::check()



#To have my own notes about this build, create a dev folder
dir.create("dev")

#Then tell R to Ignore it when building
usethis::use_build_ignore("dev")


### STEP 6 ###
#install the gitHub to connect the local package to the GitHub website
usethis::use_git()

#Before doing so, run this to set GitHub credentials
usethis::use_git_config(user.name = "Jeff Ackerman",
                        user.email = "jmaMedia@outlook.com")

### There are additional steps - ask Chat GPT - I lost track ###


### for the students to install they need to run this ###


##########################################
## ===================================
## 7036CCJ JeffsStatTools Installation
## ===================================
# Install remotes package that permits the install of a custom package
# Comment out the next line after successfully running once
install.packages("remotes")

# Install JeffsStatTools from GitHub
# Comment out the next line after successfully running once
remotes::install_github("JMA61/JeffsStatTools@v0.2.0")

# ------------------------------------------------------------
# Load JeffsStatTools automatically every time this project opens
# Place into .Rprofile to load the library each time R Studio starts
# Do not comment out this next line
# ------------------------------------------------------------
library(JeffsStatTools)

# Current functions available:
# jdesc()  - Descriptive statistics
# jfreq()  - Frequency tables
# jlm()    - Regression output

## To open help files ##
# ?jdesc
# ?jfreq
# ?jlm
#######################

## Examples ##
# jdesc(mtcars, mpg)
# jfreq(mtcars, cyl, gear)
# jlm(mpg ~ wt, data = mtcars)
#######################


############ End of Install Instructions ################



packageDescription("JeffsStatTools")
packageVersion("JeffsStatTools")

# which functions exist
ls("package:JeffsStatTools")

# code for the function
JeffsStatTools::jdesc

# run an automatic example from the roxygen documentation.
example(jdesc)


## This will update all installed package
update.packages(ask = FALSE, checkBuilt = TRUE)


################################################################
################################################################
################## To Update the Package #######################


# 1) Add a new function at the bottom of the 7036Tools.R file
# 2) Use ChatGPT to tweak that function to provide proper ROxygen information at that top
# 3) ChatGPT can also tweak the external library calls to calling explicit namespaces (libraries)
# 4) run code (in the console) like this to update the package's knowledge of any new external libraries

# This step is outdated.
usethis::use_package("haven")
usethis::use_package("labelled")

# NOTE:
# Only run use_package() when a NEW dependency is added.
# Do not run it every time you update the package.

#4b Make sure devtools is installed on local machine
# install.packages("devtools")
# library(devtools)


##########NEW UPDATE INSTRUCTIONS START HERE #################


# 5) Run this code to rebuild the docs and run a check
# paste it into ChatGPT and ask it to check things over for anything that needs altered
devtools::document()
devtools::check()


# 6) In the terminal run this - note the change to the version number:

# To Commit the new version:
git add -A
git commit -m "Update dependencies and bump version to 0.2.2"

# To Push/Upload to GitHub
git push

# To create the version tag
git tag -a v0.2.1 -m "Version 0.2.2"
git push --tags

# Verity that the tag exists:
git tag



### Students (and me) will install the latest version with:
remotes::install_github("JMA61/JeffsStatTools")

# If I wanted to install immediately on my local machine, I could add:
#   devtools::install()
# right after  devtools::check()







