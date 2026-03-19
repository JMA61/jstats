
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


