
########## NEW UPDATE INSTRUCTIONS #################

## Remember to change version number below, and in Description file
## ...can also update what was changed in this version in the git commit -m code below

# 1) Run this code IN THE CONSOLE or from here to rebuild the docs and run a check


devtools::load_all() ### To test the loading of the functions for parse errors - called again by document()
devtools::document()  # regenerates the .Rd help files and NAMESPACE from roxygen2 comments
# full CRAN-style check; you may see Quarto-related noise in the verbose output (Windows tooling quirk) —
# it does not show up in the final 0/0/0 tally and is not a real error
devtools::check()

## adds CRAN-incoming checks that require internet
## — URL validation in DESCRIPTION/roxygen, version-number feasibility against current CRAN,
##  and a few other release-readiness checks.
## Run before any release-candidate or CRAN submission; routine edits don't need this.
devtools::check(remote = TRUE)


# 2) Run this code IN THE TERMINAL - note the change to the version number:

# To Commit the new version:
git add -A

git commit -m "v0.8.3: jplot() unified plotting function"

# To Push/Upload to GitHub
git push

# To create the version tag
git tag -a v0.8.3 -m "Version 0.8.3"
git push --tags

# Verity that the tag exists:
git tag







