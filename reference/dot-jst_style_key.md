# Internal helper: one setting of a style, for one table type

The lookup of the reference (Part 3.2), layer by layer: in each, the
type's own section, then the general part; the first value found wins. A
plain list of parts (the built-in apa list) is read as one layer. A key
no layer holds is an internal error: the built-in list is complete.

## Usage

``` r
.jst_style_key(style, type, key)
```

## Arguments

- style:

  A style object, or a list of parts.

- type:

  Character(1); the table type (the section's name), or "general".

- key:

  Character(1); the key.
