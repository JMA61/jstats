# Internal helper: stop when a filter kept one category of a predictor to be dummy-coded in the call

[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
build a predictor's dummies in the call – `categorical =`, a factor, a
text or logical variable – from the filtered data, before the Case
Processing block, and with one category they stopped "'gf' has fewer
than 2 categories. Cannot create dummy variables." When a filter names
the variable it is the cause: the stop says so, with both ways out, as
for a registered predictor
([`.jst_prune_absent_categories()`](https://jma61.github.io/jstats/reference/dot-jst_prune_absent_categories.md);
Session 346). Otherwise the builder's own stop stands.

## Usage

``` r
.jst_stop_if_filter_kept_one(x, v, subset_expr, data_name)
```

## Arguments

- x:

  The variable, filtered.

- v:

  Character(1); its name.

- subset_expr:

  This call's `subset =` condition text, or `NULL`.

- data_name:

  Character(1) or `NULL`.

## Value

Invisibly `NULL`; stops when a filter kept one category.
