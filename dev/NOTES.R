
########## NEW UPDATE INSTRUCTIONS #################

## Remember to change version number below, and in Description file
## ...can also update what was changed in this version in the git commit -m code below

# 1) Run this code IN THE CONSOLE or from here to rebuild the docs and run a check
devtools::document()  # this updates the documentation - including creating help files for ?jt for example.
devtools::check()     # this is an optional more thorough check. there will be some ERROR that has to quarto - ignore.

devtools::check(remote = TRUE) ## an even more thorough check to mimic closer to what CRAN will look for


# 2) Run this code IN THE TERMINAL - note the change to the version number:

# To Commit the new version:
git add -A
git commit -m "v0.7.0: jload and jsave jlogistic - Improved/updated help files.  Improved returns for all functions to permit joutput() output control and future development."

# To Push/Upload to GitHub
git push

# To create the version tag
git tag -a v0.7.0 -m "Version 0.7.0"
git push --tags

# Verity that the tag exists:
git tag





### To load the functions into the current session use
devtools::load_all()

