# Internal helper: render a runnable jencode() call for a remedy line

Builds the prefilled, non-destructive jencode() call that
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
notes offer as a remedy: Rule G's R-suffix target, the data name from
the user's own call, and the map string filled in from the column's own
words, so the line runs as pasted. The call is emitted on one line when
it fits the 76-column message width, and otherwise breaks after the
variable with the map string continuing under its own opening quote.
Every continuation still parses, because
[`.jst_parse_text_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_text_map.md)
trims each rule.

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

  Character. Leading indent for the first line.

## Value

Character scalar; may contain newlines.
