# Internal helper: class-safe numeric coercion for haven-input columns

Equivalent to `as.numeric(x)` for every input type (numeric, factor,
Date/POSIXct/difftime, character, and haven_labelled all give the same
result, since [`unclass()`](https://rdrr.io/r/base/class.html) strips
only the class attribute), but bypasses vctrs method dispatch. A bare
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) on a
`haven_labelled` vector can abort with "Can't convert \<haven_labelled\>
to " in a fresh session where `readxl` was attached before haven
registered its `vec_cast` method (and always aborts on a
character-backed haven_labelled). Stripping the class first sidesteps
the dispatch entirely. Standardised package-wide at the haven-input
coercion sites in jdesc, jfreq, jscreen, jt, jaov, jcrosstab, jcorr,
jlm, jlogistic, jalpha, jdummy, and jrecode. (Session 50)

## Usage

``` r
.jst_as_numeric(x)
```

## Arguments

- x:

  A variable / data-frame column.

## Value

A numeric vector.
