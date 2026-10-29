# Internal helper: the file a style name or path names

Internal helper: the file a style name or path names

## Usage

``` r
.jst_style_find(style, fn, cl = NULL, mc = NULL, from = NULL)
```

## Arguments

- style:

  Character(1).

- fn, cl, mc:

  As
  [`.jst_style_resolve()`](https://jma61.github.io/jstats/reference/dot-jst_style_resolve.md).

- from:

  NULL, or where based.on named it: list(file, line, chain).

## Value

The path; stops when there is none.
