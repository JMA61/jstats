# Internal helper: front-door check that formula functions got a formula

Called at the top of the formula-interface functions (jt, jaov,
jcrosstab, jlm, jlogistic) before any output. Verifies the first input
is a formula and, when the data input was supplied, that it is a data
frame. Without this check, a swapped call like jlm(df, Income ~ Age) or
a misplaced leading-comma call like jlm(, Income ~ Age) sails past the
opening steps and crashes deep inside the data pipeline with a raw
seq_len() error. (Session 106.)

## Usage

``` r
.jst_check_formula_data(formula, data, first_name, data_name, example, fn)
```

## Arguments

- formula:

  The formula input's value, or NULL when it was missing.

- data:

  The data input's value, or NULL when it was missing.

- first_name:

  Deparsed name of the formula input (NULL when missing); used in the
  swapped-order example when the user's data frame sits there.

- data_name:

  Deparsed name of the data input (NULL when missing).

- example:

  A per-function example formula string for the generic message (e.g.
  "DV ~ Group").

- fn:

  The public function's name, for the error prefix and examples.

## Value

invisible(NULL) when the inputs pass; otherwise never returns.

## Details

Callers pass NULL for a missing formula/data input rather than the
missing value itself, so this helper can inspect both safely. The
non-data-frame data branch delegates to .jst_check_vars with an empty
name list, reusing its existing data-frame validation messages
(quoted-string, NULL, matrix, catch-all) so no wording is duplicated.
All errors route through .jst_stop(fn = fn) so the public function is
named in the prefix.
