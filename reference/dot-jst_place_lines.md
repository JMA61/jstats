# Internal helper: make an offered modify = TRUE line run for a place

`modify = TRUE` changes a data frame through its NAME, so
`jdeclare_missing(lst$d, ..., modify = TRUE)` stops ("can only change a
data frame that has a name"). Many builders paste the data argument as
typed into such a line, and a call that named a place –
`jencode(lst$d, w, map = ...)` – was offered lines that then stopped
(the S343 item; Session 345). A place can be assigned to, so the line
that runs for it is the assignment form, the one the durability reminder
has given a place since Session 339:
`lst$d <- jdeclare_missing(lst$d, ...)`.

## Usage

``` r
.jst_place_lines(lines)
```

## Arguments

- lines:

  Character vector: the physical lines of one message.

## Value

Character vector of the same length.

## Details

Done once, in the wrapper layer every emitter passes through, rather
than at each of some forty builder sites: a printed call whose FIRST
argument is a place and whose last is `modify = TRUE` always stops as
printed, whichever function built it, so the rewrite needs to know
nothing about the message it is in. A line is changed only when it is
one whole call that parses, its first argument unnamed and a place by
[`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md);
every other line is returned untouched. The place is copied as typed, up
to the first comma outside brackets and quotes. Only
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
and [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
take `modify`, and both return the data frame.
