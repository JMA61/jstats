# Internal helper: rows of a frame an active jcomplete() setting keeps

The cases Step 1 of
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
hands to a stored
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
filter: those an ACTIVE
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
setting keeps, a declared missing value counting as missing (the
setting's variables are masked for the test, as
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)'s
own count masks them; the rows returned are the frame's own). Used where
a stored filter is checked outside an analysis – when set, at
`jsubset(d, on)`, and for the status display (Session 331) – so the
check sees as many cases as the analysis will. Returns the frame
untouched when there is no active setting, or when the setting names a
variable the frame no longer has (the analysis stops on that first).

## Usage

``` r
.jst_complete_kept(data, data_name)
```

## Arguments

- data:

  The data frame.

- data_name:

  Character. Its name, the registry key.

## Value

A data frame.
