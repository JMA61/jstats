# Internal helper: names after jrelabel()'s variable that are found nowhere

The unnamed arguments of the call, other than the data frame and the
variable slot, that are bare names neither of the data frame's variables
nor of any object R can find from the caller (Session 430):
`jrelabel(d, Q1, Q5, labels = ...)` gives Q5, which R had bound to
var.label and stopped on, "object 'Q5' not found". Read from the call as
typed, so nothing is evaluated.

## Usage

``` r
.jst_relabel_lost_names(cl, data, data_sub, slot, env)
```

## Arguments

- cl:

  The call ([`sys.call()`](https://rdrr.io/r/base/sys.parent.html)).

- data:

  The data frame.

- data_sub:

  The data argument as typed.

- slot:

  The variable slot as typed, or NULL.

- env:

  The caller's environment.

## Value

Character.
