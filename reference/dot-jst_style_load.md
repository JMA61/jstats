# Internal helper: load a style by name or path, with its based.on chain

Internal helper: load a style by name or path, with its based.on chain

## Usage

``` r
.jst_style_load(
  style,
  fn,
  cl = NULL,
  mc = NULL,
  seen = character(0),
  from = NULL
)
```

## Arguments

- style:

  Character(1).

- fn, cl, mc:

  As
  [`.jst_style_resolve()`](https://jma61.github.io/jstats/reference/dot-jst_style_resolve.md).

- seen:

  The files already in the chain, for the loop check.

- from:

  NULL, or where based.on named it: list(file, line, chain).
