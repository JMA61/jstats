# Internal helper: a box plot's groups, labeled as the descriptives label them

[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md) on a
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) or
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) result drew
its boxes over the codes – 1, 2, 3, 4 – where the Group Descriptives
table of the same result reads "1: Control", "2: CBT" (Session 347; the
S344 item). The axis now takes the table's labels, which follow
`value.id` as the call that made the result resolved it. The groups are
in the table's order: a labelled variable's codes sorted, a factor's
levels in use, a text variable's values with the blank cells last, under
`<blank>`. A result whose table does not match the groups in its model
frame (one made by an older version) keeps the old axis.

## Usage

``` r
.jst_plot_group_factor(x, groups = NULL)
```

## Arguments

- x:

  The grouping variable from the result's model frame.

- groups:

  Character; the Group column of the result's descriptives, or `NULL`.

## Value

A factor.
