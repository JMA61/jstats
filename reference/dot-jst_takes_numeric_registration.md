# Internal helper: can a variable carry a numeric, count or Likert registration?

TRUE for a numeric variable and for a haven-labelled variable whose
stored values are numbers – the two storage kinds
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md) and
[`jlikert()`](https://jma61.github.io/jstats/reference/jlikert.md)
document. Read from
[`.jst_var_kind()`](https://jma61.github.io/jstats/reference/dot-jst_var_kind.md),
so a factor, a text variable (plain or value-labelled), a logical, a
date or time and the unsupported types are all FALSE. One test for the
three places that need it: the registration refusal
([`.jst_check_registration_type()`](https://jma61.github.io/jstats/reference/dot-jst_check_registration_type.md))
and the two readers of a stored registration
([`.jst_jstats_class()`](https://jma61.github.io/jstats/reference/dot-jst_jstats_class.md),
[`.jst_is_count()`](https://jma61.github.io/jstats/reference/dot-jst_is_count.md)),
which pass over one that is stored on any other kind of variable.

## Usage

``` r
.jst_takes_numeric_registration(x)
```

## Arguments

- x:

  A variable.

## Value

`TRUE` or `FALSE`.
