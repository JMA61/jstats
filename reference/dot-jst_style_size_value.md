# Internal helper: a size written as following the text size, in points

"size" is the text size itself; "size - 1" a point smaller, "size + 2"
two larger (ruling R77, Session 413). The result is kept within the
sizes a size setting takes, 6 to 72.

## Usage

``` r
.jst_style_size_value(v, size)
```

## Arguments

- v:

  Character(1): "size", or "size" with a plus or a minus and a number,
  as
  [`.jst_style_check_value()`](https://jma61.github.io/jstats/reference/dot-jst_style_check_value.md)
  writes it.

- size:

  The text size, in points.

## Value

Numeric(1).
