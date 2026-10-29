# Internal helper: make a style object

Internal helper: make a style object

## Usage

``` r
.jst_style_object(name, path, layers, skipped = character(0))
```

## Arguments

- name:

  Character(1); the style's name.

- path:

  Character(1); its file, NA for a built-in.

- layers:

  The layers, read first to last.

- skipped:

  Character; settings a newer jstats wrote, passed over.
