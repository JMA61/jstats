# Internal helper: variables listed one after another in a jrelabel() call

The unnamed arguments of the call, other than the data frame and the
variable slot, that are names of the data frame's variables:
`jrelabel(d, Q1, Q2, Q3, labels = ...)` gives Q2 and Q3 (Session 378).
Read from the call as typed, so nothing is evaluated.

## Usage

``` r
.jst_relabel_extra_vars(cl, data, data_sub, slot)
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

## Value

Character.
