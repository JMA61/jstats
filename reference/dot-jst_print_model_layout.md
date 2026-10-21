# Internal: a model's blocks in the order model.layout gives them

"fit" prints the fit block, the seam, then the coefficients; the default
the coefficients, the seam, then the fit block (S375). jlm() and
jlogistic() each held this block (Session 386, the twin build).

## Usage

``` r
.jst_print_model_layout(model_layout, coef_fn, fit_fn, seam_fn)
```

## Arguments

- model_layout:

  "fit" or "coefficients".

- coef_fn, fit_fn, seam_fn:

  The three printers, each a function of no arguments.

## Value

NULL, invisibly.
