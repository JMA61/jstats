# Internal: the stop for a call that names no variables

"no variables specified." and the function's own example on a line of
its own, for jcomplete(), jdummy(), jnumeric(), jcount(), jlikert(),
jdesc(), jfreq() and jplot() (Sessions 338, 369 and 370). One home since
Session 383; the recode family's singular form is
[`.jst_no_var_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_var_stop.md).

## Usage

``` r
.jst_no_vars_stop(example, fn = NULL)
```

## Arguments

- example:

  Character(1). The example call, without its indent.

- fn:

  Character or NULL. The function to name in the prefix; NULL takes it
  from the call stack, as
  [`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md)
  does.

## Value

Does not return; stops.
