# Internal helper: build a red-title string for jplot.default output

Produces titles like:

- Histogram: Age

- Bar Chart: Gender

- Scatterplot: Age and Tattoos

- Boxplot: Age by Gender

- Grouped Bar Chart: Program and Employment

Appends " by \<by_name\>" when a by-variable is supplied. Uses variable
names (not labels), matching the user's typed call.

## Usage

``` r
.jst_plot_title(plot_type, variable_names, by_name = NULL)
```

## Arguments

- plot_type:

  Character, one of the valid resolved types.

- variable_names:

  Character vector of 1 or 2 variable names.

- by_name:

  Optional character string for the by-variable.
