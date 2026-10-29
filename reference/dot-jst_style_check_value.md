# Internal helper: check and convert one style value

The same checks for a file's value (its text) and a call's (an R value).
A wrong value stops with what the setting takes, after the line that set
it when it came from a file.

## Usage

``` r
.jst_style_check_value(key, sp, val, type, fn, where = NULL)
```

## Arguments

- key:

  The setting's name.

- sp:

  Its entry in `.jst_style_spec`.

- val:

  A file's value (a list from
  [`.jst_style_value_text()`](https://jma61.github.io/jstats/reference/dot-jst_style_value_text.md)),
  or a call's R value.

- type:

  The part it is in, for the columns a table type has.

- fn:

  The user-facing function's name.

- where:

  For a file's value, the sentence naming the line; NULL for a call's.

## Value

The value converted: text, a lowercase choice, a number, a hex color (or
"none"), a vector of column keys, the stars' thresholds.
