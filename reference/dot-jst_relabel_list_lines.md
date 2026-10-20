# Internal helper: the lines that run jrelabel()'s list form

The call with `modify = TRUE` (Session 378): on a data frame's name, or
under the [`juse()`](https://jma61.github.io/jstats/reference/juse.md)
default, one line; on an expression, the line that names it first
(`mydata <- mk()`); on a place (`lst$d`), that and the line that puts
the result back.

## Usage

``` r
.jst_relabel_list_lines(data_sub, data_kind, default_used, vtxt, labels_sub)
```

## Arguments

- data_sub:

  The data argument as typed.

- data_kind:

  "name", "place" or "expression".

- default_used:

  Logical.

- vtxt:

  Character(1); the variables as the line gives them.

- labels_sub:

  The labels as typed, or NULL.

## Value

Character(1), the indented lines.
