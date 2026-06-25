# Internal helper: build jrecode's cross-convention error message

Produces the error message used by
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md) when
Stata-style Stata-style missing-value tokens appear in the map or labels
argument but the resolved convention is SPSS. Verbosity is controlled by
the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jrecode_convention_error(parsed_map, parsed_labels, data_name, orig_name)
```

## Arguments

- parsed_map:

  List returned by
  [`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md).

- parsed_labels:

  Named numeric vector returned by
  [`.jst_parse_labels()`](https://jma61.github.io/jstats/reference/dot-jst_parse_labels.md),
  or `NULL` if no labels argument was supplied.

- data_name:

  Character. Name of the data frame in the user's call (used to
  reconstruct the example).

- orig_name:

  Character. Name of the variable being recoded.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
