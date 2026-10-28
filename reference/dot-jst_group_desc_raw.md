# Internal: a group comparison's descriptives, unrounded, for the table layer

jt() and jaov() store their Group Descriptives as printed: each group as
its display string and Mean and SD rounded to the digits setting. A
table rounds again to its own style's places (2.4449 printed 2.445, then
2.45 at two places, where the value gives 2.44), and under digits = 1 it
would pad a one-place value. This frame keeps what the table layer reads
(Session 399, Capability Slate T's build 0): each group's code and label
and its N, mean and SD unrounded, with the 95 percent interval of the
mean in jaov()'s (a one-case group's blank, as in the printed table).
The outcome's and the grouping variable's names and labels ride as
attributes, in the regression results' form.

## Usage

``` r
.jst_group_desc_raw(gm, groups, dv_name, group_name, lab_src, ci = FALSE)
```

## Arguments

- gm:

  The groups' rows of the group front's group_map, in the printed
  table's order.

- groups:

  A list of numeric vectors, one per group in the same order: the
  outcome's values the table describes, missing values out.

- dv_name, group_name:

  Character(1); the outcome and the grouping variable.

- lab_src:

  The data frame the labels are read from.

- ci:

  Logical(1); add ci_lower and ci_upper (jaov()).

## Value

A data frame: group_code, group_label, n, mean, sd (and ci_lower,
ci_upper), with attributes outcome and group, each
`c(name = , label = )`.
