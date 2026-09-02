# Internal helper: render a count for runtime-message prose

Returns the count comma-grouped at a thousand and above. Used for counts
in message prose (cells, cases, words, variables), never for data values
or for numbers inside a runnable command line.

## Usage

``` r
.jst_fmt_n(n)
```

## Arguments

- n:

  Numeric scalar (or vector). The count.

## Value

Character vector of the same length.
