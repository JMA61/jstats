# Internal helper: what kind of thing a call gave as its data argument

Reads the data argument as typed and says whether a result can be
assigned back to it. A reassignment line built by pasting the argument
on both sides of an arrow is only R when the argument is a name or a
place: `mk() <- jconvert(mk(), ...)` is neither (the S219 item, findings
2 and 5; Session 339).

## Usage

``` r
.jst_data_arg_kind(data_sub)
```

## Arguments

- data_sub:

  The substituted data argument, or `NULL` when the call gave none and
  the [`juse()`](https://jma61.github.io/jstats/reference/juse.md)
  default was used.

## Value

`"name"` for a plain name (or `NULL`); `"place"` for a `$`,
double-bracket or slot access whose left side is itself a name or a
place (`lst$d`); otherwise `"expression"`.
