# Internal: footnote rows at the end of a data frame read from a file

The rows below the data that hold text in the first variable alone, read
from the last case up, past empty cases, as the stray-parts note finds
them (Session 365). Session 380, so the note on a variable of numbers
made text by a few cells does not take footnotes for such cells. (The
stray-parts note finds none when the run reaches the first case; here a
run that long leaves the first variable no numbers, so the note has
nothing to name either way.)

## Usage

``` r
.jst_note_rows(df)
```

## Arguments

- df:

  A data frame; a CSV file's as read, every cell text, or a sheet's.

## Value

Integer vector of row numbers.
