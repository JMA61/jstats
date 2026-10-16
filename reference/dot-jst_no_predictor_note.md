# Internal helper: the note for the plots a model with no predictors cannot draw

The note
[`.jst_no_predictor_plots()`](https://jma61.github.io/jstats/reference/dot-jst_no_predictor_plots.md)
emits, and jlm()'s diagnostics emit under their plot list (Session 359).

## Usage

``` r
.jst_no_predictor_note(dropped_labels)
```

## Arguments

- dropped_labels:

  Character; the left-out plots, named as the note gives them.

## Value

Invisible NULL; emits the note.
