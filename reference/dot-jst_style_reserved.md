# Internal helper: the names kept for built-in styles still to come

A built-in's name wins over any file, so a file saved under the name of
a built-in a later version adds would stop being read the day that
version is installed, and a file based on it would change its base.
`jstyle(save.as = )` refuses these names, as it refuses a built-in's
(Session 407). A name moves from here to
[`.jst_style_builtin()`](https://jma61.github.io/jstats/reference/dot-jst_style_builtin.md)
when its style ships: `report` did at Session 409, and none is kept now.

## Usage

``` r
.jst_style_reserved
```
