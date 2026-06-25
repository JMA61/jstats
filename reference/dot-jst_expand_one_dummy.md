# Internal helper: expand a single registration into dummy columns

Given a registration-shaped object (from jdummy storage or built
in-flight via
[`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md)),
add the dummy columns to `data` and replace `var_name` with the dummy
names in `formula_str`. Used by
[`.jst_expand_dummies()`](https://jma61.github.io/jstats/reference/dot-jst_expand_dummies.md)
and by the auto-categorical pathways in jlm and jlogistic.

## Usage

``` r
.jst_expand_one_dummy(data, formula_str, reg)
```

## Arguments

- data:

  The data frame.

- formula_str:

  The formula as a deparsed string.

- reg:

  A registration object (must have `var_name`, `codes`, `non_ref_idx`,
  `dummy_names`).

## Value

A list with components `data`, `formula_str`, `dummy_coef_names`.
