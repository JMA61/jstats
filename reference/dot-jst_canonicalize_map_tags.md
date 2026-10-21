# Internal: a map's markers in the convention's case

Every marker in the map's rules, its else rule and its NA rule, written
in the resolved convention's case (lowercase for stata, uppercase for
sas; .jst_canonical_tag()). jrecode() and jencode() each held this block
(Session 386, the twin build); each still treats the labels' markers
itself, jrecode() deferring a label's letter to a marker the result
carries (S345).

## Usage

``` r
.jst_canonicalize_map_tags(parsed_map, resolved_convention)
```

## Arguments

- parsed_map:

  The parsed map.

- resolved_convention:

  "stata" or "sas".

## Value

The parsed map.
