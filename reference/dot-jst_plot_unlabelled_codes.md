# Internal helper: the codes a categorical variable shows without a label

A variable with value labels on some of its codes and not others shows
those others by their codes (ruling R72, the S412 audit's F9): returned
for the note jtable() gives. A variable with no value labels at all is
not counted here: its values may be what they mean (a count), and a
grouping variable's codes are counted where it groups.

## Usage

``` r
.jst_plot_unlabelled_codes(x, present = NULL)
```

## Arguments

- x:

  The variable, before it was made a factor.

- present:

  The codes the chart shows.

## Value

Character; the codes with no label.
