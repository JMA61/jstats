# Internal helper: the code and the label behind each of jfreq()'s Valid rows

jfreq() tabulates a factor of display strings: a labelled variable's
values formatted under the call's value.id mode ("1: Male", "Male" or
"1") and capped at 40 columns, a numeric variable's numbers as text. The
stored Value column is that string. This returns, for each row, the
value itself and its label whole (Session 399, Capability Slate T's
build 0), from the map the tabulating branch kept: each display string
beside the code it was made from, zero rows (a labelled value no case
holds) included. A text variable, a factor and any other type have no
map: the row's text is its own code, and it has no label.

## Usage

``` r
.jst_freq_codes(value, lvl_map)
```

## Arguments

- value:

  Character; the Valid rows' Value column.

- lvl_map:

  NULL, or a list: `level` (the display strings), `code` (the code each
  was made from, the same length) and `labels` (the variable's value
  labels, or NULL).

## Value

A list: `code` (numeric or character) and `label` (character, `NA` where
there is none), one element per row.
