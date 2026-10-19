# Internal helper: variable names given to an argument, in quotes or bare

`categorical = "Age"`, `categorical = Age`,
`categorical = c(Age, "Income")`: a string, a bare name, or a
[`c()`](https://rdrr.io/r/base/c.html) of either, read as names without
evaluating them, so a bare name is the data frame's variable whatever
the workspace holds (ruling R18). Anything else – a name holding names,
a computed list – is evaluated and must give names. Session 375, for
jcrosstab()'s `categorical =`.

## Usage

``` r
.jst_names_given(sub, env, data, arg, data_name = NULL, example = "Age")
```

## Arguments

- sub:

  The argument, unevaluated.

- env:

  The caller's environment.

- data:

  The data frame.

- arg:

  The argument's name, for the stop.

- data_name:

  The data frame's name, for the not-found stop.

- example:

  A variable to name in the stop's example.

## Value

Character vector of names; empty for NULL.
