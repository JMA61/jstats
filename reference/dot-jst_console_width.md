# Internal helper: the current console width, unclamped

Returns `getOption("width")` as an integer, with no clamping to any
consumer band. R keeps this value current with the console pane, so it
is read at the point of use rather than cached: a message renders to the
pane it prints into. Falls back to R's own documented default of 80 when
the option is missing or malformed – a validity fallback, not a clamp.

## Usage

``` r
.jst_console_width()
```

## Value

Integer: the console width in columns.
