# Internal helper: hand a stored filter's fault back to the status display

The status displays
([`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) with
no arguments) run each stored filter through
`.jst_filter_mask(origin = "status")` to say whether it can still be
applied. A status display must not stop, so where the analysis-time
origin would call
[`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md)
this signals a condition of class `jst_filter_unusable` whose message is
the status line – "It cannot be applied: keep12 no longer exists." – and
the display catches exactly that class. Never reaches the user as an
error.

## Usage

``` r
.jst_filter_status_signal(text)
```

## Arguments

- text:

  Character. The status line.

## Value

Does not return.
