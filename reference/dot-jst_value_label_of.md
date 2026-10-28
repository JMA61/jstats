# Internal helper: the full value label of each code

The label a value carries in `val_labels`, whole – never cut to the
40-column cap the console's tables use – or `NA` where the value has
none (an empty label counts as none). Codes are matched as
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md)
matches them, through
[`as.character()`](https://rdrr.io/r/base/character.html), so a code and
its label pair here exactly as they pair in the printed table. Session
399 (Capability Slate T's build 0): the raw label the table layer
writes, where the stored display string carries the call's value.id form
and the cap.

## Usage

``` r
.jst_value_label_of(codes, val_labels)
```

## Arguments

- codes:

  A vector of codes, numeric or character.

- val_labels:

  A named vector, as
  [`labelled::val_labels()`](https://larmarange.github.io/labelled/reference/val_labels.html)
  returns it, or NULL.

## Value

Character, one element per code.
