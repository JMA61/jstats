# Internal helper: the line jplot() prints under a comparison's plots

jplot() on a model result says what it drew; on a
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) or
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) result it
drew the box plot alone, and said nothing. With the Q-Q plot (Session
375; ruling R14, part 2: "as jlm()'s which = "qq"") it says so in
jplot()'s words for a model: one diagnostic plot on one line, two plots
as a numbered list with the arrow buttons named, since the box plot is
then behind the Q-Q plot in the Plots pane. The box plot alone stays
silent, as it has been since jplot() drew it. None above, one blank line
after (Session 359).

## Usage

``` r
.jst_group_plot_list(drawn)
```

## Arguments

- drawn:

  Character; the names of the plots drawn, in order.

## Value

Invisible NULL.
