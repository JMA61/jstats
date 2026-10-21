# Internal: the outcome of jt() or jaov() made ready for the test

The assumption-check warning when the outcome looks categorical (Likert
outcomes and an asserted numeric role are exempt, inside
.jst_warns_seems_categorical()), then a labelled outcome made plain
numbers. jt() and jaov() each held this block (Session 386, the twin
build), after their one-category and one-case stops.

## Usage

``` r
.jst_group_dv_ready(data, dv_name, data_name, fn)
```

## Arguments

- data:

  The analysis copy.

- dv_name:

  Character(1): the outcome.

- data_name:

  Character(1): the data frame's name.

- fn:

  Character(1): the calling function.

## Value

The data, the outcome numeric.
