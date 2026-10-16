# Internal helper: the cases' categories of a dummy-coded variable

Read back from the model frame's dummy columns: a case marked by none is
in the reference category.

## Usage

``` r
.jst_case_category(mf, group)
```

## Arguments

- mf:

  The result's model frame.

- group:

  One element of `.jst_plot_variables()$groups`.

## Value

A factor, its levels the categories in code order.
