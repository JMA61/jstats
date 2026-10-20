# Internal helper: attach labels to one variable, in place

The in-place contract (Session 215): the variable IS the caller's
column; value labels and the variable label are attached to it directly,
so its class and every attribute it carries – value labels, SPSS-style
`na_values` / `na_range`, Stata-style tagged values, the variable label,
haven's display format – survive unless an argument replaces them. A
logical variable is stored as 1/0 first. Shared by both forms of
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md)
(Session 378); the checks are the caller's.

## Usage

``` r
.jst_relabel_apply(x, parsed_labels, var.label)
```

## Arguments

- x:

  The variable.

- parsed_labels:

  The parsed value labels, or NULL.

- var.label:

  Character(1) or NULL.

## Value

The labeled variable.
