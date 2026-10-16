# Internal: one cleaned name

The R9 rule: spaces and symbols at either end are dropped; any other run
of characters that are not letters, digits or underscores becomes one
underscore; nothing left gives V and the column's position (read.table's
form for an unnamed column); a name starting with a digit or an
underscore, or equal to a reserved word, gets an X; the result is kept
to the length budget. Letters are letters of any script (R, SPSS and
Stata take them); `ascii = TRUE` keeps A to Z alone, for SAS.

## Usage

``` r
.jst_clean_name(
  x,
  pos,
  reserved = function(s) s %in% .jst_r_reserved,
  ascii = FALSE,
  max_chars = 32L,
  max_bytes = 64L
)
```

## Arguments

- x:

  Character(1): the name as the file has it.

- pos:

  Its column position, for an empty result.

- reserved:

  A function of one name: TRUE when the target reserves it.

- ascii:

  Logical: letters A to Z only.

- max_chars, max_bytes:

  Length budget.

## Value

Character(1).
