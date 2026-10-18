# Internal helper: jfreq()'s footnote under a table with a blank row

Three lines, one sentence each (voice Rule E): what the row is, with the
two kinds counted apart when both occur; that it is counted as valid –
"Valid %" reads to this audience as though blanks were excluded, and
they are not; and the one way to change that. A legend printed with its
table, on stdout, as jscreen()'s star legend is.

## Usage

``` r
.jst_blank_footnote(counts, declare = TRUE)
```

## Arguments

- counts:

  A
  [`.jst_blank_counts()`](https://jma61.github.io/jstats/reference/dot-jst_blank_counts.md)
  list.

- declare:

  Logical; FALSE for a factor, whose blank levels
  [`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
  cannot declare.

## Value

Character(1), newline-joined; `""` when there is no blank.

## Details

Since Slate E5 (ruling R27) the way out names both routes, a line each:
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md) gives
the blank cells a code,
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
with `codes = ""` declares them missing. A factor gets the one
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md) line
it had, since
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
refuses a factor.
