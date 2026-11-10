# Internal helper: a text item of a set that holds what no other item holds

Under a text `ticked =`, each yes/no item of a set holds the ticked
value and at most the set's one other answer ("N", "Unchecked") beside
its blanks. An item holding a value that no other item of the set holds
is a text answer – LimeSurvey's "Other" box, Q1_other, inside a range of
items written "Y" or blank – and stops, named, with the first values it
holds.

## Usage

``` r
.jst_multi_odd_text(vals, ticked)
```

## Arguments

- vals:

  Named list: each item's values, as
  [`.jst_multi_values()`](https://jma61.github.io/jstats/reference/dot-jst_multi_values.md)
  gives them.

- ticked:

  The value counted as chosen (text).

## Value

Invisibly NULL; stops on the first such item.
