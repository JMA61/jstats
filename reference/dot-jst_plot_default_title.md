# Internal helper: a chart's default title (ruling R69)

From labels, the name where a variable has none, never naming the
chart's kind (APA: "a brief but descriptive title"): the variable alone
for a bar chart, a histogram or a density plot; the variable "by" the
group for a chart by groups, a grouped bar chart and a box plot; the
outcome "by" the predictor for a scatterplot. A panel variable adds
itself as a group does. The title stands in the figure's caption in a
Word file; title = in jtable() replaces it.

## Usage

``` r
.jst_plot_default_title(
  type,
  data,
  variable_names,
  by_name = NULL,
  facet_name = NULL,
  formula = FALSE
)
```

## Arguments

- type:

  The resolved chart type.

- data:

  The frame.

- variable_names:

  Character; the variables as the builder takes them (a scatterplot's
  and a formula box plot's predictor first).

- by_name, facet_name:

  Character(1) or NULL.

- formula:

  Logical(1); the formula form, whose outcome is second.

## Value

Character(1).
