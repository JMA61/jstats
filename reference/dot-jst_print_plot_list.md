# Internal: the list of a model's diagnostic plots

One plot: "(Diagnostic plot produced: ...)"; two or more: jplot()'s line
for a model, word for word (S347), and the numbered list. jlm() and
jlogistic() each held this block (Session 386, the twin build); each
then draws with its own plotter.

## Usage

``` r
.jst_print_plot_list(plot_which, plot_labels)
```

## Arguments

- plot_which:

  Character: the plots to draw.

- plot_labels:

  Named character: each plot's label.

## Value

NULL, invisibly.
