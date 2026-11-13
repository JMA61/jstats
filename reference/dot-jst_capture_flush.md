# Internal helper: keep the output written since the last part

Internal helper: keep the output written since the last part

## Usage

``` r
.jst_capture_flush(ctx)
```

## Arguments

- ctx:

  A scope's context
  ([`.jst_capture_open()`](https://jma61.github.io/jstats/reference/dot-jst_capture_open.md)).

## Value

`ctx`, invisibly; a part named "out" added when any output was written.
