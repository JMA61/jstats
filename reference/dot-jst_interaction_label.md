# Internal helper: show interaction names with " \* " in place of ":"

For display: splits each name on the colons OUTSIDE parentheses (so a
computed term's own colon is not read as a product) and joins the parts
with `" * "`, the form the coefficient table's interaction rows use
(AUDIT-035). Used for the VIF table's Variable column and its VIF \> 10
notes (Session 323); the returned VIF vector keeps R's `":"` names.

## Usage

``` r
.jst_interaction_label(x)
```

## Arguments

- x:

  Character vector of term names.

## Value

Character vector the same length as `x`.
