# Internal helper: the distinct stored values of a labelled grouping variable

The sorted, distinct, non-missing stored values of a haven-labelled
variable, in their own type: numbers for a numeric-backed variable (as
`sort(unique(.jst_as_numeric(x[!is.na(x)])))` always gave), strings for
a character-backed one – a string variable carrying value labels, as a
.sav file stores Sex "M" / "F". The analysis functions pair these with
the levels
[`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
builds and hand them to
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md),
which compares codes as text on both sides. Until Session 340 every site
coerced to numeric, so a character-backed variable's codes were all
`NA`: [`jt()`](https://jma61.github.io/jstats/reference/jt.md) stopped
with R's "arguments imply differing number of rows", and
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md),
[`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
and `jdesc(by = )` printed every category label empty, each with "NAs
introduced by coercion".

## Usage

``` r
.jst_group_codes(x)
```

## Arguments

- x:

  A haven-labelled variable.

## Value

A sorted vector of distinct values: character for a character-backed
variable, numeric otherwise.

## Details

A declared missing value is excluded with the system-missing cells:
[`is.na()`](https://rdrr.io/r/base/NA.html) is `TRUE` for it on a live
`haven_labelled_spss` column, and the pipeline has masked it on the
analysis copy before any caller reaches here.
