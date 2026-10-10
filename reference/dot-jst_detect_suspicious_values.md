# Internal helper: detect values that look like coded missing markers

Scans a numeric vector for values likely to be coded missing markers
(e.g. `99`, `999`, `-99`) rather than legitimate data. Two heuristics
are applied to the variable's distinct values:

1.  Any negative value whose magnitude is at least 3 times the largest
    non-negative value, when at least two distinct non-negative values
    are present – catches conventions like `-99` or `-9` for missing in
    otherwise non-negative categorical data (`-9` in a 1-3 scale), while
    leaving `-99` unflagged beside ages of 18 to 80, since 99 is less
    than 3 times 80. (Until Session 349 this entry read "any negative
    value when all other values are positive", leaving out the 3-times
    condition the code applies; the S197 item.)

2.  Any value whose magnitude is at least 5 times the largest magnitude
    among the other values – catches `99` in a 1-5 scale, `999` in a
    1-10 scale, and so on.

Does not print messages; the calling function decides how to surface the
findings.

## Usage

``` r
.jst_detect_suspicious_values(x, var_name)
```

## Arguments

- x:

  A variable (numeric or numeric-coercible).

- var_name:

  Character. The variable's name; not used by this helper but accepted
  for symmetry with callers that supply it.

## Value

A sorted, unique numeric vector of suspicious values, or an empty
numeric if none are found.
