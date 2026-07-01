# jstats

[![r-universe
version](https://jma61.r-universe.dev/jstats/badges/version)](https://jma61.r-universe.dev/jstats)
[![R-CMD-check](https://jma61.r-universe.dev/jstats/badges/checks)](https://jma61.r-universe.dev/jstats)

> Simplified statistical-analysis tools for social-science researchers
> and teachers, with output styled after commercial statistical
> software.

**jstats** provides a small, consistent set of functions for the
analyses social scientists run most often — frequencies and
descriptives, *t*-tests, ANOVA, cross-tabulations, correlation, linear
and logistic regression, and scale reliability — with sensible defaults
and clean, recognizable output. It reads data exported from commercial
statistical software such as SPSS, Stata, and SAS (via
[`haven`](https://haven.tidyverse.org/)) directly, value and variable
labels included, and stays close enough to base R that the skills you
build transfer.

It is designed for researchers moving into R from SPSS, Stata, or SAS
who want to get their analyses done without first learning a new dialect
— and it doubles as teaching infrastructure for students meeting
statistics and R at the same time.

## Installation

jstats installs as a pre-built binary from its R-universe repository, so
there is no compiler or build toolchain to set up:

``` r

install.packages("jstats",
  repos = c("https://jma61.r-universe.dev", "https://cloud.r-project.org"))
```

Then load it as usual:

``` r

library(jstats)
```

Requires R \>= 4.2.0.

## A quick taste

Every install bundles `community`, a small synthetic dataset, so these
examples run as-is:

``` r

library(jstats)

# Frequency table for a categorical variable
jfreq(community, Region)

# Descriptive statistics
jdesc(community, Age, WellbeingScore, CommuteTime)

# Independent-samples t-test (formula interface)
jt(WellbeingScore ~ Volunteer, community)

# Linear regression -- categorical predictors are dummy-coded for you
jlm(WellbeingScore ~ Age + CommuteTime + Region, community)
```

Two patterns cover the whole package: descriptive functions take the
data first, then unquoted variable names — `jfreq(community, Region)`;
group-comparison and modeling functions take a formula, then the data —
`jt(y ~ group, community)`, just as in base R.

## What’s included

Every user-facing function is prefixed `j`:

- **Describe** — `jdesc`, `jfreq`
- **Compare groups** — `jt` (*t*-test), `jaov` (ANOVA), `jcrosstab`
  (cross-tabulation)
- **Relate & model** — `jcorr` (correlation), `jlm` (linear regression),
  `jlogistic` (logistic regression)
- **Scale reliability** — `jalpha` (Cronbach’s alpha)
- **Prepare & screen** — `jscreen`, `jrecode`, `jrelabel`, `jsubset`
- **Import & export** — `jload`, `jsave`, `jconvert` (round-trip between
  SPSS, Stata, SAS, Excel, and CSV)
- **Plot** — `jplot`

Functions accept `haven`-labelled or plain numeric variables directly —
there is normally no need to convert anything to factors yourself. (A
second bundled dataset, `clinic`, offers messier data for practicing
cleaning and missing-value handling.)

## Staying up to date

jstats is under active development, and new versions appear regularly.
To update, run:

``` r

jupdate()
```

It fetches and installs the latest version in one step; restart R
afterward to load it.

## Documentation

- **Function reference** — <https://jma61.github.io/jstats/>
- **Getting-started guides** (no prior R assumed) —
  <https://jma61.github.io/jstats-guides/>

## License

jstats is free, open-source software, released under the [MIT
License](https://jma61.github.io/jstats/LICENSE).

------------------------------------------------------------------------

Created and maintained by Jeff Ackerman.
