# Internal helper: clean.names = TRUE for an example save that needs it

Session 389 (Fix Slate 28; the (S388) item). The example jsave() lines
jsave()'s stops offer – the no-filename stop's, the front-door stops'
([`.jst_jsave_example_lines()`](https://jma61.github.io/jstats/reference/dot-jst_jsave_example_lines.md)),
the no-data-frame stop's
([`.jst_jsave_no_frame_stop()`](https://jma61.github.io/jstats/reference/dot-jst_jsave_no_frame_stop.md))
– name a data frame and a file. When the data frame holds a name the
file's format refuses, the line as printed stopped on that name
(`jsave(d, "mydata.sav")` for a d holding a variable named with, which
SPSS reserves): a remedy that leads to another stop (ruling R23). Such a
line carries `clean.names = TRUE`, as the save that closes jsave()'s own
stop does since ruling R33.

## Usage

``` r
.jst_example_clean_names(df, file)
```

## Arguments

- df:

  The data frame the line saves, or NULL when the line names a
  placeholder.

- file:

  Character(1); the file the line names.

## Value

`", clean.names = TRUE"`, or `""` when the format takes every name (or
there is no data frame to read).
