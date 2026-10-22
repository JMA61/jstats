# Internal helper: an expression that gave an empty data frame by reading a column its data frame lacks

A data frame's `$` gives NULL for a name the frame lacks, so
`d[d$Agee > 40, ]` is not an error but a data frame with no rows
(Session 392), and the stop that followed said the frame "has no rows".
When an expression given as the data gives a data frame with no rows and
reads a column its frame lacks
([`.jst_expr_missing_columns()`](https://jma61.github.io/jstats/reference/dot-jst_expr_missing_columns.md)),
the not-found sentence is given instead, as for an expression that
stops; a tibble's `[` stops on the same input, and reaches the sentence
through
[`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md).

## Usage

``` r
.jst_expr_empty_stop(data_sub, value, envir)
```

## Arguments

- data_sub:

  The expression as typed.

- value:

  Its value.

- envir:

  The caller's environment.

## Value

Invisible NULL when the caller is to go on; otherwise stops.
