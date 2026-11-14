# Internal helper: a category label made into the end of a dummy's name

Session 390 (the non-English probe): every run of characters that are
not letters, combining marks or digits becomes one underscore, and the
underscores at either end are dropped – letters of ANY script, so a
Chinese, Japanese or Korean label and an accented one keep their
letters. The rule kept A to Z and 0 to 9 only, so such a label lost
every letter and the dummy was named by its code, under a note that its
value labels were not available. One rule for
[`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md)
and its `ref =` matching. (Until Session 425 an `ascii` argument kept
the A-to-Z rule for a registration stored before Session 390; ruling R87
took it out.)

## Usage

``` r
.jst_dummy_canon(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector, the same length.
