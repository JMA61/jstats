# Internal helper: style files named like a built-in style

The `.jstyle` files in the folders searched whose name, the letters'
case aside, is a built-in style's: never read, since the built-in's name
always means the built-in (Session 407).

## Usage

``` r
.jst_style_shadowed(name)
```

## Arguments

- name:

  Character(1); a built-in style's name.

## Value

Character; the files' paths, in the folders' order.
