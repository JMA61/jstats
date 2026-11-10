# Internal helper: the stop for a pie or a donut of too many categories

Ruling R66: a pie or a donut shows at most the style's pie.max
categories – 6 in both built-in styles, a setting taking 2 to 6 – of
those that have cases. Past it the call stops with two ways on, the bar
chart and combining categories with jrecode(); it never switches to a
bar chart by itself. The count is of the categories, whatever the
variable's class (the S412 audit's F3).

## Usage

``` r
.jst_plot_pie_limit(x, v, type, look, data_name, as_numbers = FALSE)
```

## Arguments

- x:

  The variable, after the pipeline.

- v:

  Character(1); its name.

- type:

  "pie" or "donut".

- look:

  The look, for pie.max.

- data_name:

  Character(1) or NULL; the data frame's name.

- as_numbers:

  Logical(1); TRUE when the call asserts the variable as numeric.

## Value

NULL, invisibly; or stops.
