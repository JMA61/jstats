
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


