# Internal helper: jencode's face-value minting note

Runs the shipped looks-like-a-coded-missing heuristic over values
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)
minted by FACE VALUE (a text `"-99"` becoming the number -99) and
returns the nudge toward
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md),
or `character(0)` when nothing is flagged. Shared by the all-numeric
automatic path and the numbers-stored-as-text repair path so the two
read identically.

## Usage

``` r
.jst_jencode_suspicious_note(x, var_name, evidence = character(0))
```

## Arguments

- x:

  Numeric vector. The encoded values.

- var_name:

  Character. The variable's name.

## Value

Character scalar, or `character(0)`.
