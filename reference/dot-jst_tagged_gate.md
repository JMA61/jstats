# Internal: the gate for a marker in a map or in labels =

When the map or the labels carry a Stata-style or SAS-style marker, the
convention it needs is resolved (the choose-first gate fires inside
.jst_resolve_convention()), and an spss resolution stops with
.jst_jrecode_convention_error(). jrecode() and jencode() each held this
block (Session 386, the twin build); jrecode() then checks its source's
SPSS-style declarations (S302), naming the marker.

## Usage

``` r
.jst_tagged_gate(parsed_map, parsed_labels, labels_tagged_raw, convention, fn)
```

## Arguments

- parsed_map, parsed_labels:

  The parsed map and labels.

- labels_tagged_raw:

  The markers as typed in labels =.

- convention:

  The call's convention.

- fn:

  Character(1): the calling function.

## Value

NULL when neither carries a marker; else list(convention, marker): the
resolved convention and the first marker as typed.
