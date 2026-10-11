# Internal helper: does a message line have the shape of a printed call?

The test
[`.jst_seg_category()`](https://jma61.github.io/jstats/reference/dot-jst_seg_category.md)
applies to a runnable line (voice Rule L): indented, and starting with a
call or an assignment. Shape only; whether the line parses is the
caller's question.

## Usage

``` r
.jst_call_shape(line)
```

## Arguments

- line:

  Character(1): one physical line.

## Value

TRUE or FALSE.
