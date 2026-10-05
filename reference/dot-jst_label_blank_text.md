# Internal helper: the blank label on the text variables of a data frame

[`.jst_label_blanks()`](https://jma61.github.io/jstats/reference/dot-jst_label_blanks.md)
over the named variables of an analysis copy.

## Usage

``` r
.jst_label_blank_text(data, vars = names(data))
```

## Arguments

- data:

  A data frame (an analysis copy, never the user's frame).

- vars:

  The variables to relabel; all of them by default. Names not in `data`
  are ignored.

## Value

`data`.

## Details

Used by [`jplot()`](https://jma61.github.io/jstats/reference/jplot.md).
The model functions do not call it: a text predictor's blank cells are
labeled where its dummies are built
([`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md),
[`.jst_expand_one_dummy()`](https://jma61.github.io/jstats/reference/dot-jst_expand_one_dummy.md)),
and a factor's levels are left as stored there, because they are matched
against a registration that may predate the label.
