# Internal: the stop for labels = or map = that is not one quoted string

jrecode(), jencode(), jrelabel() and jdeclare_missing(), each with an
example of its own (Session 383).

## Usage

``` r
.jst_one_string_stop(arg, example, fn = NULL)
```

## Arguments

- arg:

  Character(1). "labels" or "map".

- example:

  Character(1). The example string, without its quotes.

- fn:

  Character or NULL. As for
  [`.jst_no_vars_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_vars_stop.md).

## Value

Does not return; stops.
