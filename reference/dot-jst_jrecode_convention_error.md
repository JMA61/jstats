# Internal helper: build the cross-convention error message

Produces the error message used by
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md) and
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md) when
lettered missing-value markers appear in the map or labels argument but
the resolved convention is SPSS. The message states the mismatch and
names the settings-level remedies; per Rule Y it does not rewrite the
user's call. One form at every
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jrecode_convention_error(
  parsed_map,
  parsed_labels,
  per_call_convention = NULL
)
```

## Arguments

- parsed_map:

  List returned by
  [`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md),
  or by
  [`.jst_parse_text_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_text_map.md)
  for the
  [`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)
  caller.

- parsed_labels:

  Named numeric vector returned by
  [`.jst_parse_labels()`](https://jma61.github.io/jstats/reference/dot-jst_parse_labels.md),
  or `NULL` if no labels argument was supplied.

- per_call_convention:

  Character or `NULL`. The caller's raw per-call `convention` argument.
  It selects which of the two routes to an SPSS resolution the message
  describes – the call or the setting – and therefore which remedy is
  offered; it plays no part in whether the error fires. It also seeds
  the display case for a marker that carries no recorded raw spelling.

## Value

Character scalar suitable for passing to
[`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md).
