# Internal helper: can a convention gate send the call's codes to markers?

Session 389. The codes
[`.jst_gate_marker_route()`](https://jma61.github.io/jstats/reference/dot-jst_gate_marker_route.md)
can send to markers: plain numbers, at least one, none of them a marker
already, and no range in the call.

## Usage

``` r
.jst_gate_codes_plain(parsed_codes, range)
```

## Arguments

- parsed_codes:

  jdeclare_missing()'s codes, named by their labels.

- range:

  The call's range, or NULL.

## Value

TRUE or FALSE.
