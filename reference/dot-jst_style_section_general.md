# Internal helper: the general settings a table type's section sets

A general setting written under a table type's heading sets that kind of
table only (the reference, Part 3.2). This reads a style as the lookup
does, layer by layer, and returns each general setting whose value for
the type comes from a section's own line – found before any layer's
general value – so the complete copy can write the line and the printout
show it (Session 419, ruling R82's fixes: until then a complete copy
dropped the line, and its regression tables went back to the general
value with nothing said).
[plot](https://rdrr.io/r/graphics/plot.default.html) sets none: it takes
only a chart's own settings, so no layer's
[plot](https://rdrr.io/r/graphics/plot.default.html) holds a general
one.

## Usage

``` r
.jst_style_section_general(st, part)
```

## Arguments

- st:

  A style.

- part:

  Character(1); a table type.

## Value

A named list, in the general part's order: for each setting, list(value,
source).
