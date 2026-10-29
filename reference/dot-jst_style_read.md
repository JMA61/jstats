# Internal helper: read and check one style file

Reads every line first, then judges: the stamps and based.on (the
general part only); a section or a setting this version does not have –
a near miss of one it has stops with the did-you-mean, one the
written.by stamp shows a newer jstats wrote is passed over with a note
naming it, any other stops naming both causes and the settings there
are; a setting given twice, or a section opened twice, stops; every
value is checked against `.jst_style_spec` and converted.

## Usage

``` r
.jst_style_read(path, fn)
```

## Arguments

- path:

  The file.

- fn:

  The user-facing function's name.

## Value

A list: layer (source, general and the sections), based.on and its line,
skipped (character).
