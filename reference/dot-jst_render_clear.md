# Internal helper: render a pipeline-state clear message

Shared formatter for the `(NULL)` clear messages of
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md),
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md),
and [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md).
Owns the collapse layout so the three setters stay byte-identical: one
data frame renders on a single line; two or more render a header line
plus one indented `" - "` line per data frame.

## Usage

``` r
.jst_render_clear(fn_label, dnames, payloads)
```

## Arguments

- fn_label:

  Character function label used in the message prefix (e.g.
  `"jsubset"`).

- dnames:

  Character vector of data frame names being cleared.

- payloads:

  Character vector, parallel to `dnames`, giving the parenthesised "what
  was lost" text for each frame (e.g. `"had: Age < 40"` or
  `"had 2 registered: Religion, Region"`).

## Value

`invisible(NULL)`. Called for its message side effect.
