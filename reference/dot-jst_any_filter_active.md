# Internal helper: report whether any data frame has an active filter

Scans the `.jst_filter` option to see whether any data frame has filter
settings currently turned on. Used to drive informational notes about
filtering being active for some other dataset than the one currently in
use.

## Usage

``` r
.jst_any_filter_active()
```

## Value

Logical. `TRUE` if at least one data frame has an active filter setting;
`FALSE` otherwise.
