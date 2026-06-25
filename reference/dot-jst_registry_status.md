# Internal helper: render the session-wide numeric/count registration status

Backs the no-argument calls
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md) and
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md), which
both show the same unified view of the `.jst_registry` notebook (numeric
and count intents, each tagged by kind) across all data frames. Dummy
registrations live in a separate store and are shown by
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md).
Mirrors the jdummy no-argument overview layout: a single registered
frame renders a red header plus one line per variable; two or more
frames render a header plus one indented line per frame, with the
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
marked.

## Usage

``` r
.jst_registry_status()
```

## Value

`invisible(NULL)`. Called for its message side effect.
