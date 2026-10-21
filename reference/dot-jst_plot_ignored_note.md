# Internal: jplot()'s note on arguments the plot drawn does not use

line, band, equation and r2 apply only to a scatter plot with line =
"lm". When the call names any of them for a plot that does not use them,
one yellow note lists them. jplot.default() and .jst_jplot_formula()
each held this block (Session 386, the twin build).

## Usage

``` r
.jst_plot_ignored_note(jplot_call, resolved_type, line)
```

## Arguments

- jplot_call:

  The call as typed (match.call()).

- resolved_type:

  Character(1): the plot type drawn.

- line:

  The call's line argument.

## Value

NULL, invisibly; prints the note when one applies.
