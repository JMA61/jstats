# Internal helper: read an sf data frame as an ordinary data frame

An sf object is a data frame whose geometry is a list column, and sf's
own `[` method keeps that column whatever columns are asked for:
`s[, c("Age", "Score")]` returns three columns. The analysis copy's
column subsets therefore carried the geometry into
[`complete.cases()`](https://rdrr.io/r/stats/complete.cases.html) and
the like, and
[`jscreen()`](https://jma61.github.io/jstats/reference/jscreen.md),
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md) and
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) stopped on R's
"invalid 'type' (list) of argument" (the S213 container-class item;
Session 349, Jeff's lean okayed S348). Dropping the class and sf's two
attributes leaves a plain data frame – a tibble stays a tibble – whose
geometry is an ordinary list column:
[`jscreen()`](https://jma61.github.io/jstats/reference/jscreen.md) shows
it as an Unsupported row, and an analysis that names it refuses it as
any list column is refused. Spatial data stay outside production scope
(the Scope reference, Part 6): the attributes are read, the spatial
object is not used. Any other input is returned unchanged.

## Usage

``` r
.jst_plain_frame(data)
```

## Arguments

- data:

  A data frame.

## Value

`data`, without the sf class when it had one.
