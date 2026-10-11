# Internal helper: render a runnable jencode() call for a remedy line

Builds the prefilled, non-destructive jencode() call that
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
notes offer as a remedy: Rule G's R-suffix target, the data name from
the user's own call, and the map string filled in from the column's own
words, so the line runs as pasted. Always ONE line: since Session 353
the layout of a call wider than the message is the wrapper layer's
([`.jst_layout_call()`](https://jma61.github.io/jstats/reference/dot-jst_layout_call.md),
ruling R5), which breaks it after the commas between arguments and after
the semicolons between the map's rules, as it does every printed call.
Until then this builder packed the map itself, hung under the
parenthesis at a fixed 76 columns, while a longer remedy built elsewhere
ran on whole (the S255 item).

## Usage

``` r
.jst_jencode_map_call(data_name, var_name, rules_text, indent = "  ")
```

## Arguments

- data_name:

  Character. The data frame's name in the user's call.

- var_name:

  Character. The variable being encoded.

- rules_text:

  Character. The map string's contents, without the surrounding quotes.

- indent:

  Character. Leading indent for the line.

## Value

Character scalar: one line.

## Details

The map's double quotes are escaped (Session 249):
[`.jst_jencode_lhs_render()`](https://jma61.github.io/jstats/reference/dot-jst_jencode_lhs_render.md)
re-quotes a word holding a semicolon, an equals sign or a comma with
double quotes, and the map is itself a double-quoted string.
