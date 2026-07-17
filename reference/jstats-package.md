# jstats: Simplified Statistical Analysis Tools for Social Science

jstats simplifies R for users who need to do social science analyses
without being required to become experienced computer programmers first.
The package provides consistent syntax, sensible defaults, and
protection from confusing base R behaviors, while staying close enough
to base R conventions that users learn transferable skills rather than a
private dialect. Output is styled after the best conventions from
alternative applications such as SPSS, Stata, and SAS, and code syntax
is designed to ease the transition from these alternative packages into
R. While this package was originally built as teaching infrastructure
for a university-level statistics course, it has now been expanded for
the broader social science research community.

## Audience

The long-term primary audience is the broader social science
quantitative research community – criminologists, sociologists,
political scientists, psychologists, public health researchers, and
others who routinely work with Likert scales, categorical variables,
dichotomies, Cronbach's alpha, dummy-coded regression, and
`haven`-imported data from SPSS, Stata, or SAS.

During the current development phase the package is being tested
actively by students and colleagues at Griffith University, plus a
growing community of former students and collaborating instructors.
Feedback from this group shapes ongoing refinements.

## Functions by purpose

**Descriptive analysis**

- [`jdesc`](https://jma61.github.io/jstats/reference/jdesc.md) –
  univariate descriptives (mean, median, SD, range, etc.) with optional
  grouping

- [`jfreq`](https://jma61.github.io/jstats/reference/jfreq.md) –
  frequency tables for one or more variables

- [`jcorr`](https://jma61.github.io/jstats/reference/jcorr.md) – Pearson
  or Spearman correlations with significance tests

- [`jalpha`](https://jma61.github.io/jstats/reference/jalpha.md) –
  Cronbach's alpha and item-total statistics for scale reliability

- [`jscreen`](https://jma61.github.io/jstats/reference/jscreen.md) –
  data screening for outliers, ranges, and skew

**Group comparisons and modeling**

- [`jt`](https://jma61.github.io/jstats/reference/jt.md) – independent
  or paired t-test

- [`jaov`](https://jma61.github.io/jstats/reference/jaov.md) – one-way
  analysis of variance with optional post-hoc tests

- [`jcrosstab`](https://jma61.github.io/jstats/reference/jcrosstab.md) –
  cross-tabulation with chi-square and effect-size options

- [`jlm`](https://jma61.github.io/jstats/reference/jlm.md) – linear
  regression

- [`jlogistic`](https://jma61.github.io/jstats/reference/jlogistic.md) –
  logistic regression

**Variable construction**

- [`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md) –
  recode values, with optional new value labels

- [`jrelabel`](https://jma61.github.io/jstats/reference/jrelabel.md) –
  apply or replace value labels and variable label

- [`jsum`](https://jma61.github.io/jstats/reference/jsum.md) – row-wise
  sum across variables, with min-valid handling

- [`javg`](https://jma61.github.io/jstats/reference/javg.md) – row-wise
  mean across variables, with min-valid handling

**Pipeline state management**

- [`juse`](https://jma61.github.io/jstats/reference/juse.md) – set the
  default data frame used implicitly by analysis functions

- [`jsubset`](https://jma61.github.io/jstats/reference/jsubset.md) –
  activate a row-level case-selection expression applied to subsequent
  calls

- [`jcomplete`](https://jma61.github.io/jstats/reference/jcomplete.md) –
  activate listwise filtering on selected variables

- [`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md) –
  register categorical variables for dummy coding in regression

- [`joutput`](https://jma61.github.io/jstats/reference/joutput.md) – set
  session-level output verbosity (minimal / standard / full)

**Data import and export**

- [`jload`](https://jma61.github.io/jstats/reference/jload.md) – load
  data from `.rds`, `.sav`, `.dta`, `.sas7bdat`, `.xlsx`, or `.csv`

- [`jsave`](https://jma61.github.io/jstats/reference/jsave.md) – save a
  data frame, with format inferred from the file extension

**Visualisation**

- [`jplot`](https://jma61.github.io/jstats/reference/jplot.md) – base
  histograms and bar plots for data, plus method dispatch on result
  objects from [`jt()`](https://jma61.github.io/jstats/reference/jt.md),
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md), etc.

For the full alphabetical listing of every exported function, run
[`library(help = "jstats")`](https://rdrr.io/r/base/library.html) or
browse the package index.

## Workflow conventions

**The j-prefix.** Every user-facing function starts with `j`, so the
package's whole API can be discovered in RStudio by typing `j` and
pressing Tab. Internal helpers begin with a dot or `.jst_` and are not
intended for direct use.

**Formula vs data-first.** Group-comparison and modeling functions
follow the base R formula interface:
`jt(MathScore ~ Gender, data = SampleData)`. Descriptive and
data-management functions take the data frame first, followed by
unquoted variable names: `jfreq(SampleData, Gender, Program)`. This
matches the conventions of base R functions like
[`aggregate()`](https://rdrr.io/r/stats/aggregate.html) and
[`cor()`](https://rdrr.io/r/stats/cor.html).

**The juse-first habit.** A single `juse(MyData)` call at the start of a
session sets a default data frame. Subsequent analysis calls can then
omit the data argument: `jfreq(Gender)` works the same as
`jfreq(MyData, Gender)`. The default also scopes the pipeline-state
functions, so `jsubset(Age < 30)` sets a filter on the current default
without further specification.

**Pipeline stages.**
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md),
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md),
and [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
modify session state that subsequent analysis calls read automatically.
State is explicit – calls can be inspected, inactivated, and cleared,
and active state is reported in analysis output, so a script's behavior
stays visible and reproducible rather than depending on hidden context.

**Output verbosity.**
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md) sets
one of three preset levels – `minimal`, `standard` (default), or `full`
– that modulate how much detail analysis functions print. Useful for
stripping output in production scripts or expanding it during
exploration. Per-call arguments always override session-level settings.
The Case Processing Summary table follows an auto-suppress rule at the
standard tier: it prints when something happened (pipeline state,
listwise drops, or a per-variable discrepancy notification) and stays
silent otherwise. See
[`?joutput`](https://jma61.github.io/jstats/reference/joutput.md) for
the full toggle behavior.

## Where to go next

- For the full alphabetical listing of functions:
  [`library(help = "jstats")`](https://rdrr.io/r/base/library.html).

- For source, issue reports, and contribution guidelines: the package's
  GitHub repository.

- For statistics and R fundamentals (in preparation): Book 1 of the
  companion book series.

- For migration patterns from SPSS, Stata, or SAS, and a deeper guide to
  the package's design and use in real research (in preparation): Book
  2, the adopter's guide.

## See also

Useful links:

- <https://jma61.github.io/jstats/>

## Author

**Maintainer**: Jeff Ackerman <SurveyCentre@griffith.edu.au>

Authors:

- Jeff Ackerman <SurveyCentre@griffith.edu.au>
