# Internal helper: the lines jsave() prints after saving a result

Session 429: the data frame's two lines in the form of a result – what
was saved and where, then what it is, R format and the result named by
the function that made it – and the line that loads it back.

## Usage

``` r
.jst_result_saved_text(res, out_path)
```

## Arguments

- res:

  The list .jst_result_save_file() returned.

- out_path:

  The path written.

## Value

Character(1).
