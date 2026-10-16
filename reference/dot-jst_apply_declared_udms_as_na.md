# Internal helper: mask declared UDM cells to NA on the analysis copy

Internal helper: mask declared UDM cells to NA on the analysis copy

## Usage

``` r
.jst_apply_declared_udms_as_na(data, cols = names(data))
```

## Arguments

- data:

  The data frame.

- cols:

  Character; the columns to mask. Every column by default.
  [`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
  passes the analysis variables and the columns its active settings
  read, when its caller names them (Session 359, the S217 item's fix 2):
  on a 1.9-million-row frame with ten declared columns the whole-frame
  pass cost about 2.4 seconds on every analysis call, and the two
  analysis variables 0.17.
