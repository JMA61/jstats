# Internal helper: a setting jstats has, in a part that cannot take it

The four cases a style file and jstyle()'s settings share (Session 419,
ruling R82's fixes): paper under a table type's heading or under
[plot](https://rdrr.io/r/graphics/plot.default.html) – the page is the
whole Word file's, read from the general part alone; any other general
setting under [plot](https://rdrr.io/r/graphics/plot.default.html),
which a figure's frame never reads; a table type's setting before the
first section; and one section's setting under another's heading. Until
then the first two were accepted and did nothing, and the last two were
called settings jstats does not have.

## Usage

``` r
.jst_style_misplaced(k, sec)
```

## Arguments

- k:

  Character(1); the setting's name.

- sec:

  Character(1); the part it was set in: "general" or a section.

## Value

NULL when the part takes it, or it is no setting at all; else a list:
kind ("paper", "general", "section", "other") and, for the last two,
owners (the sections that have it).
