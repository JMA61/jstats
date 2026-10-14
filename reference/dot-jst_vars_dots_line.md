# Internal helper: the call rebuilt with its variables after the data frame

The line
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md) and
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
offer when the variables arrived through `vars =` in a form that does
not run there (Session 355): the call as made, `vars =` taken out, and
the variables listed bare straight after the data frame – the house
form, `jconvert(d, A, B, to = "stata", modify = TRUE)`. Every other
argument is kept as typed. A data frame given as an expression is named
first (`mydata <- mk()`), as every offered line names it (S343).

## Usage

``` r
.jst_vars_dots_line(mc, fn, vars)
```

## Arguments

- mc:

  The call, from
  [`match.call()`](https://rdrr.io/r/base/match.call.html) in the
  exported function.

- fn:

  The function's name.

- vars:

  Character; the variables, in the order they go in.

## Value

A list: `pre` ("" or the naming line with its newline), `line` (the
call, indented), and `framed` (TRUE when the call named its data frame).
