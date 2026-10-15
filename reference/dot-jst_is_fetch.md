# Internal helper: an element reached from a name by \$, @ or a literal \[\[

`.GlobalEnv$G`, `lst$G`, `e[["G"]]`, `l[[2]]` and a chain of them;
looked up with no side effect. Used by
[`.jst_frame_object()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object.md).

## Usage

``` r
.jst_is_fetch(e)
```

## Arguments

- e:

  A language object.

## Value

Logical.
