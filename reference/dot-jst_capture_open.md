# Internal helper: open an output scope's buffer

A raw connection taken as the standard output, `split` sending the
output on to the Console as well. A raw connection, not a text one, so a
line not yet ended when a note arrives is kept whole and in its place
(Session 423).

## Usage

``` r
.jst_capture_open(split)
```

## Arguments

- split:

  Logical(1); also print what is written.

## Value

The scope's context: an environment holding the connection, the bytes
already read (`off`) and the parts kept (`parts`).
