# Internal: what kind of text a file holds

Read 50,000 lines at a time, so a large CSV file is never held whole,
and by lines, so no character is split between two pieces (Session 362;
.jst_write_csv()).

## Usage

``` r
.jst_file_text_kind(path)
```

## Arguments

- path:

  The file.

## Value

"ascii" (no byte above 0x7F), "utf8" (some, and every line valid UTF-8)
or "other".
