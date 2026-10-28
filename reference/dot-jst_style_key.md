# Internal helper: one setting of a style, for one table type

The lookup order of the reference (Part 3.2): the type's own section,
then the general part. A key neither holds is an internal error, since
the built-in list is complete.

## Usage

``` r
.jst_style_key(style, type, key)
```

## Arguments

- style:

  The style list.

- type:

  Character(1); the table type (the section's name).

- key:

  Character(1); the key.
