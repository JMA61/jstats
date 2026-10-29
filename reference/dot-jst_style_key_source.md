# Internal helper: which layer a setting comes from

Internal helper: which layer a setting comes from

## Usage

``` r
.jst_style_key_source(style, type, key)
```

## Arguments

- style:

  A style object, or a list of parts.

- type:

  Character(1); the table type (the section's name), or "general".

- key:

  Character(1); the key.

## Value

Character(1): the source of the layer that holds it ("apa", a file's
name, "the call").
