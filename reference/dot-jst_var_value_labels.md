# Internal helper: value labels in val_labels() form for any variable type

Returns the variable's value labels in
[`labelled::val_labels()`](https://larmarange.github.io/labelled/reference/val_labels.html)
form (names are the labels, values are the codes) so the result can be
fed straight to
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md).
Plain numeric variables have no labels and return NULL (so value.id
degrades to bare codes). Factor and character variables get synthetic
1..k codes whose ordering mirrors
[`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md),
so they line up with a dummy registration built from the same column.

## Usage

``` r
.jst_var_value_labels(x)
```

## Arguments

- x:

  A variable (haven-labelled, factor, character, or numeric).

## Value

A named integer/numeric vector in val_labels() form, or NULL.
