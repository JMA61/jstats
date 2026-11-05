# Internal helper: a setting's note, one line per choice

A setting's `about` is held in lines; a line that opens on a choice's
name ("journal: ...") is a choice of its own, and any other continues
the line before it. The style file shows each choice on its own line and
the rest unwrapped (Session 407); the settings help page joins the
choices with "\|".

## Usage

``` r
.jst_style_about_lines(a)
```

## Arguments

- a:

  Character, the setting's about.

## Value

Character, one element per line.
