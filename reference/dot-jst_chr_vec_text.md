# Internal helper: a character vector as the R code that makes it

`"UNKNOWN"`, or `c(Refused = "REF", "Don't know" = "DK")`: each value in
double quotes, escaped; a name bare when R reads it bare, else quoted.
For the lines jdeclare_missing() offers on a text variable.

## Usage

``` r
.jst_chr_vec_text(x)
```

## Arguments

- x:

  A character vector, possibly named.

## Value

Character(1).
