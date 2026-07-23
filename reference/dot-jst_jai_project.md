# Internal helper: jai("project") – write the AGENTS.md block

Four cases: create a new file; append to an existing file with no jstats
markers; replace between intact markers (with checksum-based edit
detection); refuse and print the fresh block when the markers are
damaged. Interactive runs confirm before writing; an explicit path skips
the destination confirmation but still confirms (or, when the session
cannot ask, warns after the fact) before discarding detected hand edits.

## Usage

``` r
.jst_jai_project(path = NULL)
```
