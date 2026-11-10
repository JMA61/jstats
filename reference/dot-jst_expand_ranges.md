# Internal helper: a list of variables with its ranges written out

For a function that reads its variables one by one from the quosures
(jdesc(), jfreq()): each range `A:B` is replaced by the variables from A
to B in the data frame's order, each a quosure of its own, so the call
reads as if every one had been named (Session 416; the (S413) item). The
range is checked as
[`.jst_resolve_varrange()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_varrange.md)
checks it for jalpha(), jsum(), javg(), jmulti() and jplot(): an
endpoint that is not a variable takes the not-found stop, and endpoints
the wrong way round the stop that gives them reversed. Anything that is
not a range passes through untouched, an empty slot among them.

## Usage

``` r
.jst_expand_ranges(
  quos_list,
  data,
  fn_name,
  data_name = NULL,
  default_used = FALSE
)
```

## Arguments

- quos_list:

  A list of quosures.

- data:

  The data frame.

- fn_name:

  Character(1); the calling function.

- data_name:

  Character(1) or NULL; the data frame's name.

- default_used:

  Logical(1), as
  [`.jst_resolve_varrange()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_varrange.md).

## Value

The list, each range written out.
