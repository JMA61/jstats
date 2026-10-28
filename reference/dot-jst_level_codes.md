# Internal helper: the code and the label behind each category of a factor

An analysis turns a grouping or crosstab variable into a factor of its
categories, and stores what it printed: the factor's levels, or each
category formatted under the call's value.id mode. Neither is the
category's code. This reads the code off the cells: for each level, the
value the variable holds in the first case of that category – a labelled
variable's code, a numeric variable's number, a text variable's text
(its blank cells the one `<blank>` category) – and the level itself for
a factor, whose levels are its categories, and for any other type (a
date, TRUE/FALSE), whose printed level is its value. The label is the
value label of that code, whole, or `NA`
([`.jst_value_label_of()`](https://jma61.github.io/jstats/reference/dot-jst_value_label_of.md)).
Read off the cells, so it needs no agreement between the factor's level
order and a separately sorted list of codes. Session 399 (Capability
Slate T's build 0).

## Usage

``` r
.jst_level_codes(f, src, val_labels = NULL)
```

## Arguments

- f:

  The factor the analysis made, every level held by a case (after
  [`droplevels()`](https://rdrr.io/r/base/droplevels.html)).

- src:

  The variable the factor was made from, case for case: the same length
  and order.

- val_labels:

  The variable's value labels, or NULL.

## Value

A data frame, one row per level in level order: `level`, `code` (numeric
or character), `label` (character).
