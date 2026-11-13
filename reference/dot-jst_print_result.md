# Internal helper: print a saved result's output again

Writes the parts `jstats_output` holds, in order – the output to
standard output, each note as a message – so a saved result shows what
its call printed (Session 423). Color only where the output takes it now
([`.jst_use_color()`](https://jma61.github.io/jstats/reference/dot-jst_use_color.md)).
A result made before Session 423 holds no output, and a line says so.

## Usage

``` r
.jst_print_result(x)
```

## Arguments

- x:

  A saved result.

## Value

`x`, invisibly.
