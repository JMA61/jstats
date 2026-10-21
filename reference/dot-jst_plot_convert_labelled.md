# Internal: jplot()'s labelled variables made ready to draw

Conversion follows each variable's resolved class (var_types), never the
presence of value labels: a categorical-typed labelled variable becomes
a factor of its labels (haven::as_factor()), any other labelled variable
its underlying numbers, so the geometry and the conversion agree (a
labelled Likert as a histogram, a labelled outcome on a scatter or a
box's y-axis). var_types is indexed with `[[i]]`, which drops a name, so
identical() matches whether or not it was built named. The by variable
becomes a factor, of its value labels when it has them. jplot.default()
and .jst_jplot_formula() each held this block (Session 386, the twin
build).

## Usage

``` r
.jst_plot_convert_labelled(data, variable_names, var_types, by_name, has_by)
```

## Arguments

- data:

  The data frame being plotted.

- variable_names:

  Character: the plotted variables, in the order of var_types.

- var_types:

  Character: each variable's resolved class.

- by_name:

  Character(1) or NULL: the by variable.

- has_by:

  Logical(1): whether a by variable is in use.

## Value

The data frame, converted.
