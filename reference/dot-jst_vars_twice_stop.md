# Internal helper: variables named both after the data frame and in vars =

Until Session 355 the stop read "Use either unquoted variable names
(...) or quoted names via vars = c(...), but not both." – a rule about
two forms, with R's "(...)" in it. It now says what the call did and
gives the call with every variable named once, after the data frame
(ruling R18: the house form).

## Usage

``` r
.jst_vars_twice_stop(mc, fn, dot_names, vars)
```

## Arguments

- mc:

  The call, from
  [`match.call()`](https://rdrr.io/r/base/match.call.html).

- fn:

  The function's name.

- dot_names:

  Character; the variables given after the data frame.

- vars:

  The evaluated `vars`.

## Value

Does not return.
