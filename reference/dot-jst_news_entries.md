# Internal helper: the entries of a NEWS.md between two versions

An entry is a level-one heading naming the package and a version – "#
jstats 0.9.252", a "v" before the number or anything after it allowed –
and the lines under it up to the next level-one heading. A level-one
heading with no version ("# jstats (development version)") is no entry.
Kept: the entries newer than `from` and no newer than `to`, newest first
whatever the file's order.

## Usage

``` r
.jst_news_entries(lines, from, to)
```

## Arguments

- lines:

  Character vector: the file's lines.

- from, to:

  Version strings.

## Value

A list of entries, each a list with `version`, `title` (the heading as
text) and `body` (its lines).
