# Internal helper: locate the jstats block markers in a file

Returns the line indices of every start and end marker found (empty
integer vectors when absent). The caller decides intact vs damaged:
exactly one of each, start before end, is intact.

## Usage

``` r
.jst_agents_block_bounds(lines)
```
