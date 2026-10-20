# Internal helper: variable names typed without quotes in vars =

`vars =` takes a character vector – the stored or computed list of
names, `vars = names(d)` or `vars = myvars` – and so R evaluates it:
`jconvert(d, vars = c(A, B), to = "stata")` stopped with R's "object 'A'
not found", and a workspace object named `A` would have been read for
its contents (the S351 item). Bare names are the house form after the
data frame, and that is where this check sends them (Session 355, ruling
R18): when `vars =` was given a name or a
[`c()`](https://rdrr.io/r/base/c.html) of names, and one of them is a
variable of the data frame or they do not give a character vector, the
call stops with the call rebuilt, the names after the data frame – a
workspace object that shares a variable's name is never read. A name the
data frame lacks gets the not-found sentence instead. A name holding
names (`myvars <- c("A", "B")`) that is not itself a variable of the
data frame is the programmatic form and passes, as does every computed
form.

## Usage

``` r
.jst_vars_bare_names(
  vars_sub,
  env,
  data,
  data_name,
  mc,
  fn,
  dot_names = character(0),
  as_c = FALSE,
  force = NULL
)
```

## Arguments

- vars_sub:

  The `vars` argument, unevaluated.

- env:

  The caller's environment.

- data, data_name:

  The data frame and its name.

- mc:

  The call, from
  [`match.call()`](https://rdrr.io/r/base/match.call.html).

- fn:

  The function's name.

- dot_names:

  Character; variables also given in the dots.

- as_c, force:

  As
  [`.jst_vars_dots_line()`](https://jma61.github.io/jstats/reference/dot-jst_vars_dots_line.md)
  (Session 378,
  [`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md)).

## Value

Invisible NULL; stops on bare names.
