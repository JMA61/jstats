# Internal: jsave()'s note on declared missing values saved as plain NA

Session 361 (the S218 item). `preserve.declarations = FALSE` makes every
declared missing value plain NA before the write, and since this session
it does so ahead of the .sav, .dta and .xpt pre-flight. After a write to
any format but Excel and CSV (whose loss note gives the same count),
this note says what happened: the cells that held a declared value – an
SPSS-style code, or a Stata-style or SAS-style marker – or, when none
did, that the declarations were dropped.

## Usage

``` r
.jst_jsave_blanked_note(n)
```

## Arguments

- n:

  Integer, the cells blanked.

## Value

Character scalar.
