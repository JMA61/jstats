
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

git commit -m "v0.8.0: jplot() unified plotting function

- S3 generic with methods for all jst_* result objects (jplot.jst_lm,
  jplot.jst_logistic, jplot.jst_ttest, jplot.jst_anova, jplot.jst_corr,
  jplot.jst_chisq)
- Data-first path for distributions (histogram, bar, grouped bar)
- Formula-first path for relationships (scatterplot, boxplot) consistent
  with jlm() / jaov() / jt() syntax
- line = 'lm' | 'loess' | 'connect' with equation, R-squared, and band
  options (ci, pi, see, none) for teaching homoskedasticity
- Per-group regression lines and equations via by =
- Pipeline integration: jfilter and jcomplete apply based on dataset name
  (SPSS FILTER / USE ALL convention); yellow status notes highlight
  session state; helpful errors for SPSS-style AND/OR/= syntax mistakes
- jfilter now accepts jfilter(data, expr) signature
- Defensive fixes to .jst_get_filter / .jst_get_complete getters
- Variable labels used on plot axes (truncated at 35 chars if long)
- Red title on plot console output; all session-state notes now yellow"

# To Push/Upload to GitHub
git push

# To create the version tag
git tag -a v0.8.0 -m "Version 0.8.0"
git push --tags

# Verity that the tag exists:
git tag







