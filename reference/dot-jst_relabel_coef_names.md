# Internal helper: relabel cleaned coefficient names with variable labels

For the `"labels"` variable.id display mode (jlm / jlogistic). Given the
cleaned names from
[`.jst_clean_coef_names()`](https://jma61.github.io/jstats/reference/dot-jst_clean_coef_names.md)
– numeric predictors as the bare variable name, factor terms and numeric
dichotomies as `"<var> (<level>)"`, intercept as `"(Intercept)"` –
replaces the variable-name portion of each term with the variable's
label, preserving the parenthetical decoration. Grouped / jdummy term
keys in `"<var><sep><level>"` form (e.g. `sep = "_"`) are relabelled the
same way, keeping the `"<sep><level>"` suffix. The intercept, and any
term not attributable to a labelled IV (e.g. a clearly-named jdummy
column carrying no variable label), are left unchanged. Display only:
the returned coefficient table keeps the cleaned variable names so
downstream code and the user's own indexing still work.

## Usage

``` r
.jst_relabel_coef_names(coef_names, data, iv_names, sep = "-")
```

## Arguments

- coef_names:

  Character vector of cleaned coefficient names.

- data:

  Data frame used to fit the model (carries variable labels).

- iv_names:

  Character vector of IV names from the model formula.

- sep:

  Character separator for grouped / jdummy term keys
  (`"<var><sep><level>"`). Default `"-"`; the grouped-dummy call sites
  pass `"_"`.

## Value

Character vector the same length as `coef_names`.
