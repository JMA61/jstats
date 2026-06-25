# Internal helper: print a string in red using ANSI escape codes

Works in RStudio, most terminals, and R Markdown HTML output. Falls back
to plain text in environments that strip ANSI codes.

## Usage

``` r
.cat_red(x)
```
