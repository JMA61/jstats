# Internal helper: a variable's categories, for a chart of parts of a whole

A pie, a donut and a 100% stacked bar show a variable by its categories,
whatever its class (the S412 audit's F3: the redirect a bar chart takes
with no type =, here for every variable): a labelled variable by its
codes, each named by its value label; a factor by its levels; any other
variable by its values. Read after the pipeline, so a declared missing
value is no category.

## Usage

``` r
.jst_plot_categories(x, as_numbers = FALSE)
```

## Arguments

- x:

  The variable.

- as_numbers:

  Logical(1); TRUE for a labelled variable the call asserts as numeric
  (numeric =, count =, or a registration), which is shown by its codes.

## Value

A list: key (each case's category as text, NA where missing), keys (the
categories, in order), labels (each category's value label, NA for
none), numeric (TRUE when the categories are numbers) and kind
("labelled", "factor", "text" or "number").
