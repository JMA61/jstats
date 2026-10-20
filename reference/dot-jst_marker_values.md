# Internal: a variable of numbers that a few other cells made text

Ruling R31, question 5 (Jeff, S380): N/A, - or . in a variable of
numbers makes it text, and jstats never assumes such a cell is missing
(a dash is "nil or rounded to zero" in an ABS table). The values found
are named, with the line that reads them as missing. "A few": at most
five values that are not numbers, and numbers in more than half the
cells that are not empty (Jeff's okay of the lean, S380), so a Yes/No
variable with a stray 3 is never told to read Yes and No as missing.

## Usage

``` r
.jst_marker_values(x, max_values = 5L)
```

## Arguments

- x:

  The variable's cells, empty ones and any not to count left out by the
  caller or left in (an empty cell is not counted).

- max_values:

  The most values that are not numbers.

## Value

NULL, or list(values, counts): the values in the order first met.
