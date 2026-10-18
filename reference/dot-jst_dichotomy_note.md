# Internal helper: the note on a predictor coded as a dichotomy other than 0/1

jlm() and jlogistic() (Session 347 wording). Since Session 374 (the
remedy-line audit; lean okayed S371) the jdummy() line is offered only
where jdummy() would take the variable as it stands: the variable as
given – unfiltered, as jdummy() reads it – has two categories, and their
dummy names can be made (codes -1 and 1 both give x_1, and jdummy()
stops). An expression given as the data, which jdummy() refuses, gets no
line either. Without the line the note says what to reach, a 0/1
variable.

## Usage

``` r
.jst_dichotomy_note(v, coding, x_in, data_name, data_kind)
```

## Arguments

- v:

  Character; the predictor's name.

- coding:

  "1/2" or "other", from
  [`.jst_is_dichotomy()`](https://jma61.github.io/jstats/reference/dot-jst_is_dichotomy.md).

- x_in:

  The variable in the frame as given, before any filter.

- data_name:

  Character; the data frame's name.

- data_kind:

  "name", "place" or "expression".

## Value

Character(1), the note.
