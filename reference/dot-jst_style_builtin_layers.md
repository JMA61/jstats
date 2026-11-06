# Internal helper: a built-in style's layers

The built-in's own list, then the lists of the built-ins it is based on,
apa last: report reads its own values, then apa's.

## Usage

``` r
.jst_style_builtin_layers(b)
```

## Arguments

- b:

  Character(1); a built-in style's name.

## Value

A list of layers, each a parts list with its source.
