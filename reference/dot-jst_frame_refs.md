# Internal helper: the data frames an expression names outside the data

Every name in `e`
([`.jst_expr_symbols()`](https://jma61.github.io/jstats/reference/dot-jst_expr_symbols.md))
that is not a variable of the data and that resolves in `enclos` – the
formula's environment, or the caller's frame for a condition – to a data
frame. Such a name is read from the RAW frame when the expression is
evaluated: the transform resolver and the filter both evaluate with the
analysis copy as data and `enclos` as enclosure, so `d$Income` reaches
the user's own `d`, where declared missing values are still numbers and
no stored filter has run. (Session 323; the S322 data-frame exception.)

## Usage

``` r
.jst_frame_refs(e, data_names, enclos)
```

## Arguments

- e:

  A language object (a formula term or a condition).

- data_names:

  Character vector: the analysis data's variable names.

- enclos:

  The environment the expression's other names resolve in.

## Value

Character vector of data frame names, possibly empty.
