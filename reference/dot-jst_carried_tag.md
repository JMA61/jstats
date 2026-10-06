# Internal helper: the marker a typed letter names on a given variable

[`.jst_canonical_tag()`](https://jma61.github.io/jstats/reference/dot-jst_canonical_tag.md)
with one deferral (Session 345; the S247 item): a letter whose canonical
case no cell carries, while cells do carry the other case, names the
marker the cells carry. Only a variable holding markers in both letter
cases can differ from the canonical answer. Before 0.9.218,
`codes = c(Refused = ".a")` under a sas resolution on a variable with .a
and .B cells put the label on .A, a marker in no cell, and left the .a
cells unnamed.

## Usage

``` r
.jst_carried_tag(tag, convention, carried)
```

## Arguments

- tag:

  Character vector of single tag letters, any case.

- convention:

  The resolved convention.

- carried:

  Character vector: the tag letters the variable's cells carry, as
  [`haven::na_tag()`](https://haven.tidyverse.org/reference/tagged_na.html)
  returns them (NA entries ignored).

## Value

Character vector of tag letters, the length of `tag`.

## Details

Cells only, never value labels: a label-only marker is the state this
deferral exists to avoid creating. A letter carried in both cases, or in
neither, keeps its canonical case (Decision 13: typed case carries no
meaning).
