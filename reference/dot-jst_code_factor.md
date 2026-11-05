# Internal helper: a labelled variable as a factor of its codes

The factor an analysis groups or tabulates a labelled variable by: one
level for each distinct code the cases hold, in code order – the order
[`.jst_group_codes()`](https://jma61.github.io/jstats/reference/dot-jst_group_codes.md)
gives – each level named by the code's value label, else by the code
itself, as
[`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
names them. Where two codes would take one name (a label used for two
codes, or a code that reads as another code's label) each of them is
named in the "code: label" form, "1: Other" and "2: Other", so no two
codes ever share a level.
[`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
names its levels by label and merges codes whose labels match, so two
codes labelled "Other" were one group in
[`jt()`](https://jma61.github.io/jstats/reference/jt.md),
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md),
[`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
and `jdesc(by = )` and one bar in
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md) (the
(S399) colliding-labels item; Session 407). A declared missing value
still live on a `haven_labelled_spss` column is missing, not a level
([`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
makes it one; the callers' columns are masked by then, so none of them
meets one); a labelled value no case holds is not a level either, where
[`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
made one that every caller then dropped.

## Usage

``` r
.jst_code_factor(x)
```

## Arguments

- x:

  A haven-labelled variable, numeric- or character-backed.

## Value

A factor, case for case with `x`.
