# Internal helper: the names a chart gives a set of categories

Each category by its value label, else by its code; where two names
print alike, those categories as "code: label" (the Session 407 rule, as
[`.jst_code_factor()`](https://jma61.github.io/jstats/reference/dot-jst_code_factor.md)
names a variable's categories).

## Usage

``` r
.jst_plot_category_names(keys, labels)
```

## Arguments

- keys:

  Character; the categories.

- labels:

  Character; each one's value label, NA for none.

## Value

Character; the names, unique.
