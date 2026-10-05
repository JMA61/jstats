# Internal helper: print text in yellow, where the output draws color

Used for informational/status notes where the text should be visually
distinct from regular output but not alarming (matches the
"warning/note" color convention). Yellow in the RStudio Console; plain
text everywhere else. See
[`.jst_use_color()`](https://jma61.github.io/jstats/reference/dot-jst_use_color.md).

## Usage

``` r
.cat_yellow(x)
```
