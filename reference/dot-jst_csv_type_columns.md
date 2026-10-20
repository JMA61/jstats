# Internal: type the variables of a CSV file read as text

Ruling R31 (Jeff, S380). jload() reads every cell of a CSV file as the
file has it (`colClasses = "character"`, no value read as missing) and
types each variable here, as read.csv() would –
[`utils::type.convert()`](https://rdrr.io/r/utils/type.convert.html)
after the word NA is made missing, so a variable that keeps its type is
what read.csv() gave – except:

- a variable of numbers holding a whole number written with a leading
  zero (0800, 007, not 0 or 0.5), or a whole number of more than 15
  digits, stays text, its empty cells and the word NA missing, and is
  reported for the note (question 1, question 2);

- a variable of TRUE/FALSE holding T or F standing alone stays text, as
  written (question 3), with no note;

- in a text variable the word NA stays a word (question 4), unless the
  variable is numbers except a few cells, where the word NA and an empty
  cell are missing, as in a variable of numbers, and the cells are
  reported for the note (question 5);

- a `text =` variable is left as the file has it, NA and all, and `na =`
  values are missing everywhere else (question 6).

## Usage

``` r
.jst_csv_type_columns(df, text_pos = integer(0), na = NULL, header = TRUE)
```

## Arguments

- df:

  The file as read, every variable character.

- text_pos:

  Positions named in `text =`.

- na:

  `na =`'s values, or NULL.

- header:

  jload()'s `header`: read with FALSE, a text variable whose first cell
  is a word is not named by the note on a few cells, since that line may
  be the names.

## Value

list(df, kept, markers): kept a list of list(pos, why ("zero" or
"long"), n, examples); markers a list of list(pos, values, counts).
