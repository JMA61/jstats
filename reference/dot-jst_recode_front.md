# Internal: jrecode()'s and jencode()'s front

The first argument resolved (a data frame, the juse() default, or the
variable typed with the data left out), the variable named from either
slot (ruling R18: a quoted name read as the bare one), the frame and
not-found checks, and the data's kind for the lines offered: an
expression given as the data is named mydata (S343), and the data left
out under a default is the default frame's name (S371) – data_sub, R's
missing-argument marker then, is read only for explicit data. jrecode()
and jencode() each held this block (Session 386, the twin build).

## Usage

``` r
.jst_recode_front(
  fn,
  data_sub,
  data_missing,
  var_sub,
  var_missing,
  envir,
  call,
  fun
)
```

## Arguments

- fn:

  Character(1): "jrecode" or "jencode".

- data_sub, data_missing:

  substitute(data) and missing(data).

- var_sub, var_missing:

  The variable slot's expression and whether it was given (orig.var for
  jrecode(), var for jencode()).

- envir, call, fun:

  parent.frame(), sys.call() and sys.function() of the caller.

## Value

list(data, data_name, var_name, data_kind, data_typed, arg1).
