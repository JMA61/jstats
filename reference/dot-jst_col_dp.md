# Internal helper: decimal places needed to display a numeric column

Values reaching the table renderer are already rounded at their source
(round(x, digits_n)). This returns the number of decimal places needed
to show such a column faithfully: each finite value is written to `cap`
decimal places with `formatC(format = "f")` and its trailing zeros are
removed; the count of decimals that remain is that value's requirement,
and the column-wise maximum is returned so the whole column shares one
decimal width (the decimal-point alignment the renderer relies on). The
fixed-format write avoids the magnitude-scaled tolerance of a
round()/all.equal test, which under-resolves trailing decimals for
larger-magnitude values (e.g. 40.0599999 collapsing to 40.06). The cap
(default 7, the joutput digits maximum) bounds an unrounded
full-precision value reaching the renderer. An all-NA / non-finite
column returns 0.

## Usage

``` r
.jst_col_dp(x, cap = 7L)
```

## Arguments

- x:

  A numeric vector (one already-rounded table column).

- cap:

  Integer. Maximum number of decimal places to consider (default 7, the
  joutput digits ceiling).

## Value

Integer scalar: the number of decimal places needed to display `x`
faithfully, capped at `cap`. Returns 0 for an all-NA or non-finite
column.
