# Internal: jsum() and javg()'s note on declared SPSS-style values

At joutput("full") only: where declared SPSS-style missing values were
treated as missing for the calculation, as the analysis pipeline reports
its conversions (Session 383 gave the two copies one home).

## Usage

``` r
.jst_scale_udm_note(udm_conv)
```

## Arguments

- udm_conv:

  List. The conversion record, with a converted element holding each
  variable's n_cells.

## Value

NULL, invisibly.
