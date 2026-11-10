# Internal helper: one setting of a style as the style holds it

As
[`.jst_style_key()`](https://jma61.github.io/jstats/reference/dot-jst_style_key.md),
the value as written: a size that follows the text size stays "size" or
"size - 1", for the files jstyle() writes and the settings it prints
(ruling R77: a complete copy writes them as following size).

## Usage

``` r
.jst_style_key_raw(style, type, key)
```

## Arguments

- style:

  A style object, or a list of parts.

- type:

  Character(1); the table type (the section's name), or "general".

- key:

  Character(1); the key.
