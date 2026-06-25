# Internal helper: report whether any data frame has active complete-case settings

Scans the `.jst_complete` option to see whether any data frame has
complete-case settings currently turned on. Used to drive informational
notes about complete-case handling being active for some other dataset
than the one currently in use.

## Usage

``` r
.jst_any_complete_active()
```

## Value

Logical. `TRUE` if at least one data frame has active complete-case
settings; `FALSE` otherwise.
