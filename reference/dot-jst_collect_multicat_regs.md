# Internal helper: collect multi-category dummy registrations for grouping

Gathers the registration-shaped objects for the MULTI-category dummy
variables in a fitted model, from both pathways that create dummies:
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
registrations and the in-flight auto-categorical / `categorical =`
registrations built inside jlm()/jlogistic(). A registration qualifies
only when it produced two or more dummy columns and at least one of
those columns is actually in the model. The two-or-more gate is what
keeps single-contrast variables – 0/1 and 1/2 numeric dichotomies, and
jdummy-registered two-level variables – out of the grouped layout, so
their coefficient rows are left exactly as they are.

## Usage

``` r
.jst_collect_multicat_regs(dummy_regs, auto_cat_regs, dummy_coef_names)
```

## Arguments

- dummy_regs:

  List of jdummy registrations (from
  [`.jst_get_dummy()`](https://jma61.github.io/jstats/reference/dot-jst_get_dummy.md)),
  or NULL.

- auto_cat_regs:

  Named list of in-flight registrations keyed by variable name (the
  stored object carries no `var_name` field, so it is set here from the
  list name).

- dummy_coef_names:

  Character vector of dummy column names present in the fitted model.

## Value

A list of registration objects, each guaranteed to have `var_name` set
and two or more `dummy_names`.
