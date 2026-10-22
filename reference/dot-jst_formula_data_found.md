# Internal helper: the formula functions' data frame found nowhere

jt(), jaov(), jcrosstab(), jlm() and jlogistic() read their data
argument at the front door, and a name found nowhere – jt(Score ~ Group,
dd) – stopped there in R's own words, "object 'dd' not found", with no
prefix. Called by
[`.jst_check_formula_data()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_data.md)
before that read, after the formula's own refusals (Session 391, ruling
R36): a name that is no object stops in the house voice, "jt(): 'dd' not
found.", and when the formula's variables are all in one data frame
whose name is within two letters of it, the stop offers the call with
that data frame (.jst_misspelled_frame(), .jst_misspelled_frame_stop()).
A name that is an object, and an expression, are left to the checks that
follow.

## Usage

``` r
.jst_formula_data_found(data_sub, formula, envir, cl, fn)
```

## Arguments

- data_sub:

  The data argument as typed.

- formula:

  The formula given.

- envir:

  The caller's environment.

- cl:

  The call as typed.

- fn:

  Character(1). The user-facing function's name.

## Value

Invisible NULL when the name is an object or not a name; stops
otherwise.
