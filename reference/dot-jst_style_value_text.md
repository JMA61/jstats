# Internal helper: a value's text in a style file

The text after the equals sign: a value in double or single quotes is
read as quoted (a \# inside it is text); a color written with its \# –
\#1F3864 – keeps it; otherwise a \# at the start or after a space opens
a comment.

## Usage

``` r
.jst_style_value_text(v)
```

## Arguments

- v:

  Character(1).

## Value

A list: text (the value), raw (the value as written, the comment
removed) and quoted (logical).
