# Internal helper: the model functions' variable lists, bare or quoted

`numeric =`, `categorical =` and `count =` in
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
name variables, so under ruling R18 they take names bare or in quotes, a
[`c()`](https://rdrr.io/r/base/c.html) of either, each read by
[`.jst_names_given()`](https://jma61.github.io/jstats/reference/dot-jst_names_given.md)
without evaluating a bare name (Fix Slate 22, Session 376:
`categorical = Region` had stopped with R's own "object 'Region' not
found"). A name holding names, or a computed list, is evaluated as
before.

## Usage

``` r
.jst_model_name_args(
  subs,
  env,
  data,
  data_name,
  example = "Age",
  default_used = FALSE
)
```

## Arguments

- subs:

  Named list of the arguments, unevaluated (each from
  [`substitute()`](https://rdrr.io/r/base/substitute.html) in the
  calling function).

- env:

  The caller's environment.

- data:

  The data frame.

- data_name:

  The data frame's name, for the not-found stop.

- example:

  A variable to name in the stop's example.

- default_used:

  Logical; passed to
  [`.jst_names_given()`](https://jma61.github.io/jstats/reference/dot-jst_names_given.md).

## Value

The same named list, each element a character vector of names or `NULL`
when none was given.

## Details

Since Session 377 also
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md)'s,
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md)'s and
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md)'s
`numeric =` and `count =` (and
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md)'s
`categorical =`).
