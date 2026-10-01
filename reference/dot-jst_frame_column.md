# Internal helper: a first argument typed as a data frame's column

Recognizes `d$Stress`, and `d[["Stress"]]` with a single quoted name,
where `d` is a name for a data frame in `envir` (Session 324). The
resolver reads it before evaluating the argument: a misspelled column
evaluates to NULL, which its empty-object guard would describe as an
object holding nothing, and data.frame's dollar sign partial-matches
`d$Str` to `Stress` where `jdesc(d, Str)` finds no such variable.
Anything else – a frame reached through a list, `d[, 2]`, a computed
vector – gives NULL and is evaluated as before.

## Usage

``` r
.jst_frame_column(e, envir)
```

## Arguments

- e:

  The substituted first argument.

- envir:

  The environment the argument would be evaluated in.

## Value

NULL, or a list of `frame` (the data frame's name), `var` (the column
named) and `present` (TRUE when the frame has a column of exactly that
name).
