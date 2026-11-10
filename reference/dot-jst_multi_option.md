# Internal helper: an option's text, the set's shared text taken off

Internal helper: an option's text, the set's shared text taken off

## Usage

``` r
.jst_multi_option(lab, sh)
```

## Arguments

- lab:

  The item's label.

- sh:

  [`.jst_multi_shared()`](https://jma61.github.io/jstats/reference/dot-jst_multi_shared.md)'s
  result.

## Value

Character(1): the label after the shared start, a closing bracket or
parenthesis that matches its opening one taken off; the whole label when
it does not start so.
