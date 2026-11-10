# Internal helper: what a set of items is titled and how each is named

Ruling R69: a set of items is titled by the text its labels share, each
item named by what its label adds to it, as jmulti() titles a
multiple-response set
([`.jst_multi_shared()`](https://jma61.github.io/jstats/reference/dot-jst_multi_shared.md));
labels that share no text title the chart "Responses by Item" and name
each item by its label. An item with no label is named by its name.
Under labels = "names" every item is named by its name.

## Usage

``` r
.jst_plot_item_names(data, items, by_names = FALSE)
```

## Arguments

- data:

  The frame.

- items:

  Character; the items.

- by_names:

  Logical(1); TRUE to name the items by their names.

## Value

A list: title (character(1)) and labels (named character, one per item).
