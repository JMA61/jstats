# Internal helper: an expression given as the data, read with its warnings held

For the reads of an expression given as the data (Session 392): its
value, or the error it raised, with any warning R raised on the way held
back rather than printed. A read that stops the call drops them – a
tibble's "Unknown or uninitialised column" after the not-found sentence
said the same thing again – and one that goes on gives them back
([`.jst_release_warnings()`](https://jma61.github.io/jstats/reference/dot-jst_release_warnings.md)),
as the stored filter's read does.

## Usage

``` r
.jst_read_held(f)
```

## Arguments

- f:

  A function of no arguments that reads the expression.

## Value

A list: `value`, `failed`, `error` (when it failed) and `warnings`.
