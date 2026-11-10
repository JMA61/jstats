# Internal helper: the type = of a chart drawn from a formula

A formula draws a scatterplot or a boxplot. Until Session 416 any other
`type =` given with a formula – a histogram, a bar chart, a name jplot()
does not know – went on to print its title and an N line and then
"NULL", no chart having been drawn. It stops, with the line that draws
that kind of chart: a generic example, since the kind named may not suit
the variables of the formula.

## Usage

``` r
.jst_plot_formula_type(type)
```

## Arguments

- type:

  The call's `type`.

## Value

NULL, invisibly; stops for a type a formula does not draw.
