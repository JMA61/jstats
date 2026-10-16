# Internal helper: the plots a model with no predictors cannot draw

The intercept-only model (`y ~ 1`, supported since Session 359) gives
every case the same fitted value and the same leverage, and has no
predictor to put on an axis: a fit line, an effect plot, a coefficient
or VIF plot, and the plots drawn against the fitted values or the
leverage have nothing to show. Those named in `skip` are left out of
`plot_set`, and one note names them.

## Usage

``` r
.jst_no_predictor_plots(plot_set, model, skip, labels, note = TRUE)
```

## Arguments

- plot_set:

  Character; the plots asked for.

- model:

  The fitted model.

- skip:

  Character; the plots of `plot_set` such a model cannot draw.

- labels:

  Named character; each plot's name as the note gives it.

- note:

  Logical; emit the note here (FALSE returns the names and leaves the
  note to the caller,
  [`.jst_no_predictor_note()`](https://jma61.github.io/jstats/reference/dot-jst_no_predictor_note.md)).

## Value

`plot_set` without the plots left out, with the left-out names as the
attribute `"dropped"`.
