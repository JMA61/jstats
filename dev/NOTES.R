
########## NEW UPDATE INSTRUCTIONS #################

## The "Master" file (jstats_source.R) has the 17 current jstats R files in it with the #<<<FILE: dividers (sentinels)
## My computer keeps the package as 17 separate R files,
## the master is the receive-transfer copy; data.R and zzz.R transfer separately by hand when they change."
## To install on my computer:

## Download the jstats_source.R file from Claude and over-write the existing file of that name in the root of jstats
## This file is listed in .gitignore and .Rbuildignore so it won't become part of the package
## Then run:

source("jstats_dev_tools.R")
receive_package("jstats_source.R")

## That's a function that's inside jstats_dev_tools.R

## That function will:
# back up the current files in R/
# split the master into the 17 files that go into the R folder
# does a byte-identical self-check
# runs devtools::document()
# runs a full devtools::check()


### Getting:   Non-standard file/directory found at top level:'jstats.Rproj' That will be handled later at CRAN Submission

## the R/data.R file is the roxygen documentation for the community dataset
## Running document() generates community.Rd, which is the help page seen by typing ?community
## R/data.R needs to be edited and re-delivered when the dataset's documentation needs to change (even if the dataset doesn't change)
## This file is not within the jstats_source.R file.
## Also not in the jstats_source.R master file is zzz.R, so those two files will need to be transferred separately if they change

# "If source("jstats_dev_tools.R") runs but receive_package still isn't found, suspect a file mix-up —
# the master's content saved into the dev-tools filename.
# Check readLines("jstats_dev_tools.R", n=1); if line 1 is a #<<<FILE: sentinel,
# that's the master in the wrong filename, not a code problem.
# The dev script must never contain sentinels; the master must never contain the dev functions."


### When going in reverse : assemble_package() would take the 17 files and place them into the jstats_source.R file that I would upload to Claude
## but I would only need to run assemble_package() if any of the 17 files were hand edited on my machine. Otherwise, the jstats_source.R file is
## simply uploaded to Claude when necessary.

assemble_package()   ## No argument is necessary - - the output defaults to jstats_source.R; reads the 17 R/ files automatically

## again, only if any of the 17 files are edited on my machine.
### if no local edits are done, the jstats_source can be re-uploaded to the KB from the last delivered, but running assemble_package() does an extra check






## Remember to change version number below, and in Description file
## ...can also update what was changed in this version in the git commit -m code below

# 1) Run this code IN THE CONSOLE or from here to rebuild the docs and run a check


devtools::load_all() ### To test the loading of the functions for parse errors - called again by document()
heldevtools::document()  # regenerates the .Rd help files and NAMESPACE from roxygen2 comments
# full CRAN-style check; you may see Quarto-related noise in the verbose output (Windows tooling quirk) —
# it does not show up in the final 0/0/0 tally and is not a real error
devtools::check()

### to get the actual new version of the package installed on the development machine without pushing run this:
### restart afterwards - to get to the state of any actual session
devtools::install()


## adds CRAN-incoming checks that require internet
## — URL validation in DESCRIPTION/roxygen, version-number feasibility against current CRAN,
##  and a few other release-readiness checks.
## Run before any release-candidate or CRAN submission; routine edits don't need this.
devtools::check(remote = TRUE)

## Committing and pushing a new version

## When ready to commit, use the Git tab in the upper right pane.
## Tick the boxes next to all files you want to include in the commit (this is called "staging" in git terminology).
## Click Commit — a popup window appears.
## Enter a commit message, then click Commit in the popup.
## This saves a snapshot of the changes in your local repository, ready to be pushed to GitHub when you're done.
## You can make multiple commits before pushing — each one is its own snapshot.
## When ready to upload to GitHub, click Push (the upward green arrow).
## Push uploads every local commit that GitHub doesn't have yet — possibly several at once if you've made multiple commits since the last push.
## Before pushing, glance at the indicator next to the branch name (e.g. "↑3") to confirm how many commits you're about to publish.
## Alternatively, follow the terminal commands below.



# 2) Run this code IN THE TERMINAL - note the change to the version number:

# To Commit the new version:
# Stage and commit (skip if already done in RStudio)
git add -A
git commit -m " {comments go here same below } "

# Create annotated tag BEFORE push so --follow-tags carries it up
git tag -a v0.8.7 -m "v0.8.7: jfreq case processing + unified dummy naming"

# Push commits and associated annotated tags together
git push --follow-tags

# Verify
git tag -l "v0.8.7"

## to show all uploads under version 8.x    (Unnecessary)
git tag -l "v0.8.*"

j
