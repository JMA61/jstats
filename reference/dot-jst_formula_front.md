# Internal: a formula function's data frame, named or the juse() default

jt(), jaov(), jcrosstab(), jlm() and jlogistic() each held this block
(Session 386, the twin build). Given no data frame, the juse() default
is resolved, or the resolver's stop raised; given one, its name is the
expression as typed (deparse()), and the data are left for the caller to
read where it always has.

## Usage

``` r
.jst_formula_front(data_missing, data_sub, envir)
```

## Arguments

- data_missing:

  Logical(1): missing(data) in the caller.

- data_sub:

  The data argument's expression (substitute(data)).

- envir:

  The caller's calling frame (parent.frame()).

## Value

list(data, data_name, default_used); data is NULL when a data frame was
given.
