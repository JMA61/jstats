# Internal: the note for a data folder just created

A folder named relative to the working directory keeps the sentence
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) has
always printed. An absolute path (a drive letter, a leading separator,
or a leading tilde) is not "in working directory", and goes on a line of
its own so that no wrap can break it.

## Usage

``` r
.jst_data_dir_created_note(dir)
```

## Arguments

- dir:

  Character(1). The folder just created.

## Value

Character(1), the note text.
