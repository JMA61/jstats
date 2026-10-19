# Internal helper: the stop on a cross-tabulation variable with more than 20 values

A variable measured on a scale and cross-tabulated by mistake –
jcrosstab( Age ~ Sex) – printed a table of one row per age (the
large-crosstab item, built Session 375 at the lean of 20). Past 20
values the call stops, naming each such variable and its count (several
in one stop, voice Rule AJ), with the call that tabulates it anyway: the
call as typed with `categorical =` naming it, so it runs as printed.

## Usage

``` r
.jst_crosstab_values_cap(levels_list, names, cat_names, call, cap = 20L)
```

## Arguments

- levels_list:

  List of the two variables' categories.

- names:

  Character(2); the variables.

- cat_names:

  Character; the variables `categorical =` names.

- call:

  The call, from [`sys.call()`](https://rdrr.io/r/base/sys.parent.html).

- cap:

  Integer; the most values a variable may have.

## Value

Invisible NULL, or stops.
