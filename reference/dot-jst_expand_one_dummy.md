# Internal helper: expand a single registration into dummy columns

Given a registration-shaped object (from jdummy storage or built
in-flight via
[`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md)),
add the dummy columns to `data` and substitute the variable's symbol in
the parsed `formula` with the parenthesized dummy block
`(d1 + d2 + ...)`. Substitution walks the formula object and compares
symbols by identity (the resolver's sub_term pattern), so a backticked
computed-column name can never be partially matched the way the retired
deparse-and-gsub rewrite could (AUDIT-028/-029). Used by
[`.jst_expand_dummies()`](https://jma61.github.io/jstats/reference/dot-jst_expand_dummies.md)
and by the auto-categorical pathways in jlm and jlogistic.

## Usage

``` r
.jst_expand_one_dummy(data, formula, reg)
```

## Arguments

- data:

  The data frame.

- formula:

  The model formula (a formula object).

- reg:

  A registration object (must have `var_name`, `codes`, `non_ref_idx`,
  `dummy_names`).

## Value

A list with components `data`, `formula`, `dummy_coef_names`.
