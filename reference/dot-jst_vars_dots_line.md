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
.jst_vars_dots_line(mc, fn, vars, as_c = FALSE, force = NULL)
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

- as_c:

  Logical; the variables as one [`c()`](https://rdrr.io/r/base/c.html).

- force:

  Named character; arguments set on the line, replacing the call's own
  (`c(modify = "TRUE")`).

## Value

A list: `pre` ("" or the naming line with its newline), `line` (the
call, indented), and `framed` (TRUE when the call named its data frame).

## Details

[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md)
(Session 378) takes its list in one slot, as a
[`c()`](https://rdrr.io/r/base/c.html): `as_c = TRUE` gives the
variables as one [`c()`](https://rdrr.io/r/base/c.html) (one name bare)
and drops the call's own `var`; `force` sets arguments the line must
carry – its list form runs only with `modify = TRUE`, so the line
carries it (ruling R23: no line that stops next).
