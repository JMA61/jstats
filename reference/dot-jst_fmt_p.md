# Internal helper: format a p-value for display

Formats one or more p-values to three decimal places following the
package convention: the leading zero is dropped (a p cannot exceed 1, so
".045" not "0.045"), values below .001 collapse to the "\<.001" floor,
and a missing p renders as the empty string (a blank cell) rather than a
misleading "\<.001" or a stray "NA". Vectorized; used by every analysis
function that prints a p-value, matching jcorr's existing treatment.
Statistics that can exceed 1 (F, t, Wald, chi-square, coefficients,
standard errors, confidence-interval bounds) keep their leading zero and
are formatted elsewhere – this helper is for p-values only. The
three-decimal precision is fixed and does not follow the digits option
(p-values keep their own convention).

## Usage

``` r
.jst_fmt_p(p)
```

## Arguments

- p:

  Numeric vector of p-values (NA allowed).

## Value

Character vector the same length as p.
