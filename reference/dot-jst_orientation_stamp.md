# Internal helper: build the version-stamp line(s)

One line naming the orientation-text version, the jstats version it was
generated against, and the date. When regenerate names a jai() setup
value ("project" or "machine"), a second line carries the regenerate
instruction; the live console print passes NULL (a fresh print cannot go
stale, so it carries no regenerate line).

## Usage

``` r
.jst_orientation_stamp(regenerate = NULL)
```
