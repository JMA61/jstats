# Visualize jst\_\* result objects or plot variables directly from a data frame

Unified plotting function. Can be called in three ways:

## Usage

``` r
jplot(x, which = "core", ...)

# Default S3 method
jplot(
  x,
  ...,
  by = NULL,
  type = NULL,
  line = FALSE,
  equation = TRUE,
  r2 = TRUE,
  band = "ci",
  subset = NULL,
  labels = NULL,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  facet = NULL,
  style = NULL
)

# S3 method for class 'jst_lm'
jplot(
  x,
  which = "core",
  focal = NULL,
  at = "zero",
  equation = TRUE,
  r2 = TRUE,
  ...,
  style = NULL
)

# S3 method for class 'jst_logistic'
jplot(x, which = "core", focal = NULL, at = "zero", ..., style = NULL)

# S3 method for class 'jst_ttest'
jplot(x, which = "core", ..., style = NULL)

# S3 method for class 'jst_anova'
jplot(x, which = "core", ..., style = NULL)

# S3 method for class 'jst_corr'
jplot(x, which = "core", ..., style = NULL)

# S3 method for class 'jst_crosstab'
jplot(x, which = "core", ..., style = NULL)

# S3 method for class 'jst_desc'
jplot(x, which = "core", ...)

# S3 method for class 'jst_freq'
jplot(x, which = "core", ...)

# S3 method for class 'jst_alpha'
jplot(x, which = "core", ...)

# S3 method for class 'jst_multi'
jplot(x, which = "core", ..., style = NULL)
```

## Arguments

- x:

  A result object from one of the package's analysis functions
  (result-object form), or a data frame (data-first form).

- which:

  Character vector. `core` (default), `all`, or one or more specific
  plot names valid for the object's class. (Result-object form only.)

- ...:

  Additional arguments: for the result-object form these are passed to
  class-specific methods; for the data-first form these are unquoted
  variable names (1 or 2; for `type = "stacked"` a set of items, which a
  range such as `Q1:Q5` may name).

- by:

  Unquoted variable name for group-coloring (data-first form). With
  `type = "stacked"`, the groups: one bar for each.

- type:

  Character. Plot type override for the data-first form. One of
  `histogram`, `density`, `bar`, `scatter`, `box`, `grouped_bar`, `pie`,
  `donut`, `stacked`. If NULL (default), auto-detected from variable
  types; `density`, `pie`, `donut` and `stacked` are never the automatic
  choice.

- line:

  Controls a line overlay on data-first scatter plots. One of `FALSE`
  (default; no line), `TRUE` (alias for `lm`), `lm`, `loess`, `connect`.

- equation:

  Logical. If TRUE (default), displays the equation in the subtitle for
  `line = "lm"` scatter plots (data-first form) or `jst_lm` `fit` plots
  (result-object form).

- r2:

  Logical. If TRUE (default), displays R-squared in the subtitle
  alongside the equation.

- band:

  Character. Uncertainty band type for `line = "lm"` scatter plots. One
  of `ci` (default; 95% confidence band for the mean, flares at the
  ends), `pi` (95% prediction interval for individual observations),
  `see` (constant-width band at +/- t\*SEE; useful for teaching
  homoskedasticity), `none`.

- subset:

  Optional unquoted logical expression to filter cases for this call
  only (data-first form). Written in R syntax and checked the way
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  checks a filter: `subset = NOT(Age < 40)`, for example, is refused
  with the corrected `subset = !(Age < 40)` shown (see
  [`jsubset`](https://jma61.github.io/jstats/reference/jsubset.md) for a
  translation table).

- labels:

  Character or NULL. How the chart names its variables (data-first and
  formula forms). NULL (the default) and `"labels"` title each axis and
  legend with the variable's label, the name where it has none;
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` does not reach a chart, as it reaches no table.
  `"names"` uses the variables' names; `"legend"` and `"legend.bottom"`
  keep names on the axes and print a console label legend; `"both"` is
  accepted and renders as `"names"`. Not a logical.

- numeric:

  Optional. Plotted variables to treat as continuous for this call (the
  per-call counterpart of
  [`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md)),
  named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html): `numeric = Education`. In
  `jplot()` a variable's class chooses the geometry, so this forces
  numeric handling (histogram for a single variable; scatter / numeric
  axis in the formula and two-variable forms). Applies to the plotted
  variables only, not the `by` grouping variable.

- categorical:

  Optional. Plotted variables to treat as categorical for this call (the
  per-call counterpart of
  [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) for
  plotting purposes), named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html). Forces categorical geometry
  (bar for a single variable; box / categorical axis in the formula
  form). A variable cannot be listed in both `categorical` and
  `numeric`/`count`.

- count:

  Optional. Plotted variables to treat as counts for this call (the
  per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)),
  named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html). A count is numeric-like for
  plotting, so it draws the same as `numeric`; it is provided for
  symmetry with the other analysis functions.

- facet:

  Unquoted variable name for one panel per group (variable-list form: a
  histogram, density plot, bar chart or grouped bar chart), bare or in
  quotes. See Details.

- style:

  The publication style the chart is drawn in, a name in quotes:
  `"apa"`, `"report"`, or the name of a style file (see
  [`jstyle`](https://jma61.github.io/jstats/reference/jstyle.md)). NULL
  (the default) uses `joptions(style = )`, apa when it is not set. The
  style's `[plot]` section gives the chart's look, and
  [`jtable()`](https://jma61.github.io/jstats/reference/jtable.md)
  frames the chart in the same style.

- focal:

  Unquoted name of the predictor to place on the x-axis for `jst_lm` /
  `jst_logistic` `fit` and `probability` plots. Defaults to the first
  predictor in the model that is not dummy-coded, since a fitted line
  needs a numeric axis. A dummy-coded categorical variable is named as
  the formula names it (`focal = Region`), and is drawn with its
  categories along the axis: the predicted outcome (or probability) at
  each with its 95% confidence interval, the cases behind them.

- at:

  Character string or named list specifying where non-focal predictors
  are held when drawing the fitted line in `jst_lm` / `jst_logistic`
  methods. One of `zero` (default), `mean`, `mixed` (categorical at 0,
  interval at mean), or a named list `list(Var1 = value, ...)`. A term
  computed from the focal variable alone, or from it and variables held
  – a square, `I(x^2)`; a log, `log(x + 1)` – is not held: it is
  computed from the focal variable at each point of the line, so the
  line of a model with a squared term is a curve.

## Value

Invisibly, the chart: a `ggplot` object of class `jst_plot`, which keeps
what a figure needs – its kind, its N, its default title from labels and
the data it shows – for
[`jtable()`](https://jma61.github.io/jstats/reference/jtable.md); it
remains a ggplot, so `+` adds to it. For a result drawn in several plots
(result-object form), a named list of them, which
[`jtable()`](https://jma61.github.io/jstats/reference/jtable.md) takes
as one figure each.

## Details

**Result-object form:** Pass a result object returned by one of the
package's analysis functions. Produces appropriate plots for each class
of result (see valid plot names below).

**Formula form** (for plots that distinguish an outcome from a
predictor): Pass a formula as the first argument, followed optionally by
a data frame, given either positionally or as `data = `:
`jplot(WellbeingScore ~ Income, data = community)` is the same plot as
`jplot(WellbeingScore ~ Income, community)`. Used for scatterplots and
boxplots, consistent with the formula syntax of
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md),
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md), and
[`jt()`](https://jma61.github.io/jstats/reference/jt.md). The outcome on
the left of `~` goes on the y-axis; the predictor on the right goes on
the x-axis. Only one predictor is supported here; for a model of
several, fit with
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and pass the
result to `jplot()`. Each side names a variable as it stands: a computed
term such as `log(Income)` or `I(Age > 40)` is refused, so create it as
a variable of the data first.

**Variable-list form** (for distributions and counts): Pass a data frame
followed by one or two unquoted variable names. The data frame is given
either positionally or as `data = `: `jplot(data = community, Age)` is
the same plot as `jplot(community, Age)`. Used for histograms (1
numeric), bar charts (1 categorical), and grouped bar charts (2
categorical), and, asked for with `type =`, for pie and donut charts and
100% stacked bars (see "Parts of a whole" below). Calls that would
otherwise auto-detect to a scatter or boxplot produce a helpful error
directing you to the formula form. A range, `Environment1:Environment5`,
names every variable from the first to the last in the data frame's
order, as in
[`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md).

**A labelled variable with a few categories**, such as Region – six
values or fewer with at least one of them labelled, or whole numbers
from 0 to 6 – is drawn as categories when nothing says otherwise: alone,
as a bar chart; beside another variable in the variable-list form, as
one of a grouped bar chart's two variables or as a boxplot's groups (the
error then gives the formula line); on the right of a formula, as the
groups of a boxplot. This is for the plot only: the analysis functions
read such a variable as numbers unless it is registered or asserted (see
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md)).
`numeric =` or `count =`, a
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md) or
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)
registration, a `type`, or `line`, `band`, `equation` or `r2` (which
only a scatter plot draws) keeps the numbers.

Supports pipeline integration (`jsubset`, `jcomplete`, per-call
`subset`), grouping via `by = `, and regression lines with
equation/R-squared/band annotations.

**The look.** A chart is drawn in a publication style's look – the
style's `[plot]` section: its font and size, its colors, its gridlines
and axis lines, where its legend goes. Both built-in styles draw in
greys, Arial 10 on white, bars from zero; `"apa"` with both axis lines,
no gridlines and the legend at the right, `"report"` with light
horizontal gridlines, the x axis line alone and the legend at the top. A
chart's axes and legends are titled by the variables' labels, the name
where a variable has none; a bar chart of one series shows each bar's
count, a pie or a donut each slice's percentage and a ranked bar chart
each bar's (the style's `values`); a 100% stacked bar shows its
percentages inside its segments only under the style's
`values.stacked = yes`. Percentages are whole numbers, or have one
decimal place under `values.decimals = 1`. The style is
`joptions(style = )`'s, apa when none is set, or the call's `style =`.

**A chart in a Word file.** Keep a chart with `<-` and give it to
[`jtable()`](https://jma61.github.io/jstats/reference/jtable.md): it
goes into the Word file as a figure, numbered, its title – the
variables' labels – in the caption with N after it, in the style it was
drawn in (see
[`jtable`](https://jma61.github.io/jstats/reference/jtable.md)).

Valid plot names by class (for the result-object form):

- `jst_lm`: `fit`, `predicted`, `effects`, `coef`, `residuals`, `qq`,
  `scale`, `cooks`, `leverage`

- `jst_logistic`: `probability`, `logit` (the same fitted line on the
  log-odds scale, where it is straight: the linear predictor and its 95%
  band against the focal variable, the cases as a rug along the axis,
  those with the outcome at the top and the others at the bottom; at a
  dummy-coded focal variable's categories, the log-odds at each), `roc`,
  `calibration`, `binned`, `cooks`, `leverage`, `coef`

- `jst_ttest`, `jst_anova`: `box` (the default), `qq` (a normal Q-Q plot
  of the standardized residuals: each case's distance from its group's
  mean, or for a paired test each pair's difference from the mean
  difference)

- `jst_corr`: `heatmap`, `scatter` (scatter requires exactly 2 variables
  in the correlation)

- `jst_crosstab`: `bar` (the default), `stacked` (a 100% stacked bar:
  one bar per group – the variable on the right of the formula – with
  the row variable's distribution within it, the column percentages of
  the crosstab; for the other way round, swap the formula. The chart
  follows the percentages the publication table prints: under a style
  file whose `[crosstab]` `percent.base` is `row`, one bar per category
  of the row variable)

- `jst_multi` (a
  [`jmulti()`](https://jma61.github.io/jstats/reference/jmulti.md)
  result): `bar`, a ranked bar chart – one horizontal bar per option in
  the order of the result's table, "None of these" last, each bar's
  percentage of everyone who answered at its end

The shortcut keyword `core` (default) produces a curated default set for
the class; `all` produces every plot the class supports.

For a `jst_lm` result, `effects` draws one plot per variable of the
model: a term computed from a variable (`I(x^2)`, `log(x + 1)`,
`I(x * z)`) is drawn in that variable's plot, following it along the
axis, with the other variables held as `at` sets them. A dummy-coded
categorical variable is one variable, drawn as one plot: its categories
along the axis, labeled as the coefficient table labels them, with the
predicted outcome at each and its 95% confidence interval. A variable
the fit dropped as an exact linear combination of the others has no
effect to draw. For a model with no predictors (`y ~ 1`), the plots that
need a predictor, or that are drawn against the fitted values or the
leverage, are left out with a note.

Valid plot types for the data-first form: `histogram`, `density`, `bar`,
`scatter`, `box`, `grouped_bar`, `pie`, `donut`, `stacked`. A density
plot is the histogram's alternative for a numeric variable – its kernel
density estimate, one curve, or one per group of `by =` laid over each
other – and is drawn only when asked for with `type = "density"`.

**Parts of a whole.** Three charts show how a whole divides, and each is
drawn only when asked for by name. They draw a variable by its
categories whatever its type, each category named by its value label;
the whole is the cases with an answer. A
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md) or
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)
registration, which says how the analyses read a variable, changes
nothing in these charts; `numeric =` in the call shows a labelled
variable by its codes.

- `type = "pie"` and `type = "donut"`: one variable as one whole. The
  slices are its categories that have cases, clockwise from 12 o'clock
  in the variable's own order, each labelled beside it with its
  percentage; no legend. A pie shows at most six categories (the style's
  `pie.max`): a variable with more stops, with the line that draws a bar
  chart. `by =` and `facet =` are refused – to show a variable within
  groups, draw a 100% stacked bar.

- `type = "stacked"`: a 100% stacked bar, horizontal bars whose segments
  are a variable's categories and sum to 100. With `by =`, one variable
  within each group:
  `jplot(community, Education, by = Region, type = "stacked")` draws a
  bar for each region. With several variables and no `by =`, a set of
  items that share their answer categories – the items of a scale – one
  bar per item:
  `jplot(community, Environment1:Environment5, type = "stacked")`. The
  items must share one set of categories (their value labels; unlabelled
  items, their values), and each bar's whole is that item's own valid
  answers. The legend is above the chart in the segments' order. A
  [`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
  result draws the same chart: `jplot(ct, which = "stacked")`.

In the variable-list form `facet =` draws one panel per group of the
variable named, with the groups' value labels as the panel titles: the
alternative to `by =` when the groups are many, since colors laid over
each other stop being readable past a handful. The two can be combined,
`by =` coloring the groups of one variable within each panel of another.
A scatterplot or boxplot by groups takes `by =` in the formula form;
`facet =` is refused there.

Valid `line` values: `FALSE` (default), `TRUE` (alias for `lm`), `lm`,
`loess`, `connect`.

Valid `band` values: `ci` (default confidence band around the regression
line, flares at the ends), `pi` (prediction interval for individual
observations, wider), `see` (constant-width +/- t\*SEE band illustrating
the homoskedasticity assumption), `none` (no band).

## Methods (by class)

- `jplot(default)`: the default method: a scatter or box plot from a
  formula (`Outcome ~ Predictor`), or a histogram or bar chart from a
  data frame and one or more variables.

- `jplot(jst_lm)`: diagnostic, coefficient (forest), and fitted-effect
  plots for a [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md)
  linear-regression result.

- `jplot(jst_logistic)`: predicted-probability (S-curve) and coefficient
  plots for a
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
  result.

- `jplot(jst_ttest)`: a group-comparison box plot for a
  [`jt()`](https://jma61.github.io/jstats/reference/jt.md) result, with
  the group means marked; `which = "qq"` draws the normal Q-Q plot of
  its residuals.

- `jplot(jst_anova)`: a group-comparison box plot for a
  [`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) result,
  with the group means marked; `which = "qq"` draws the normal Q-Q plot
  of its residuals.

- `jplot(jst_corr)`: a heat-map of the correlation matrix for a
  [`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) result,
  or a scatter plot for a single pair.

- `jplot(jst_crosstab)`: a grouped bar chart of cell counts for a
  [`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
  result; `which = "stacked"` draws the 100% stacked bar, one bar per
  group.

- `jplot(jst_desc)`: (planned) direct plotting of a
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md) result
  is not yet available; this method points you to the data-first form,
  for example `jplot(data, Variable)`.

- `jplot(jst_freq)`: (planned) direct plotting of a
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md) result
  is not yet available; this method points you to the data-first form,
  for example `jplot(data, Variable)`.

- `jplot(jst_alpha)`: a
  [`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md)
  result is not drawn; this method says so and points you to the
  data-first form for its items, for example `jplot(data, Item1)`.

- `jplot(jst_multi)`: the ranked bar chart of a multiple-response set,
  for a [`jmulti()`](https://jma61.github.io/jstats/reference/jmulti.md)
  result: one bar per option in the order of the result's table, "None
  of these" last, each bar's percentage of everyone who answered at its
  end.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Result-object form
m <- jlm(WellbeingScore ~ Income + Age, community)
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Income
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE     t      β      p
#> -----------  ------  -----  -----  -----  -----
#> (Intercept)  24.815  3.749  6.620         <.001
#> Income        0.000  0.000  6.813  0.564  <.001
#> Age           0.181  0.082  2.208  0.183   .030
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.411    Adjusted R-squared: 0.398
#> Residual Standard Error: 9.013
#> 
#> F-statistic: 32.729 on 2 and 94 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 5317.416
#>   Residual:   7635.945
#>   Total:      12953.361
#> 
jplot(m)                            # core diagnostics + fit plot




jplot(m, which = "coef")            # coefficient forest plot
#> `height` was translated to `width`.

jplot(m, which = "fit", focal = Age, at = "mean")


# Formula form (scatter and box)
jplot(WellbeingScore ~ Income, community)               # scatter
#> Scatterplot: WellbeingScore and Income
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(WellbeingScore ~ Income, community, line = "lm")  # + regression line
#> Scatterplot: WellbeingScore and Income
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(WellbeingScore ~ Income, community, line = "lm", band = "see")
#> Scatterplot: WellbeingScore and Income
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(WellbeingScore ~ Income, community, by = Volunteer, line = "lm")
#> Scatterplot: WellbeingScore and Income by Volunteer
#> 
#> Analysis N: 97 (6 Excluded)
#> 


# Boxplot: a labelled variable with a few categories, such as Region,
# is drawn as groups on the right of the formula (for the plot only)
jplot(WellbeingScore ~ Region, community)
#> Boxplot: WellbeingScore and Region
#> 
#> Analysis N: 103
#> 

# categorical = asserts it in any variable; numeric = keeps the codes
jplot(WellbeingScore ~ Region, community, categorical = "Region")
#> Boxplot: WellbeingScore and Region
#> 
#> Analysis N: 103
#> 


# Variable-list form (distributions and counts)
jplot(community, Age)                      # histogram
#> Histogram: Age
#> 
#> Analysis N: 103
#> 

jplot(data = community, Age)               # the same, data frame as data =
#> Histogram: Age
#> 
#> Analysis N: 103
#> 

jplot(community, Region)                   # bar chart
#> Bar Chart: Region
#> 
#> Analysis N: 103
#> 

jplot(community, Region, Volunteer)        # grouped bar chart
#> Grouped Bar Chart: Region and Volunteer
#> 
#> Analysis N: 103
#> 


# A chart kept, then written to a Word file as a figure
p1 <- jplot(community, Region)
#> Bar Chart: Region
#> 
#> Analysis N: 103
#> 

jtable(p1, file = file.path(tempdir(), "Figure1.docx"), overwrite = TRUE)
#> Figure 1. Region of residence (N = 103)
#>   a bar chart, 6 by 4 inches, on a portrait page.
#> Figure written to /tmp/RtmppH5BxR/Figure1.docx
#> 

# The report style's look
jplot(community, Region, style = "report")
#> Bar Chart: Region
#> 
#> Analysis N: 103
#> 


# Parts of a whole, each asked for by name
jplot(community, Region, type = "pie")
#> Pie Chart: Region
#> 
#> Analysis N: 103
#> 

jplot(community, Region, type = "donut")
#> Donut Chart: Region
#> 
#> Analysis N: 103
#> 

# A 100% stacked bar: one variable within groups, or a set of items
jplot(community, Education, by = Region, type = "stacked")
#> 100% Stacked Bar Chart: Education by Region
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(community, Environment1:Environment5, type = "stacked")
#> 100% Stacked Bar Chart: Environment1 to Environment5
#> 
#> 103 Cases in the 5 Variable Pool; 84 Complete on All
#> 

# ... and from a crosstab
ct <- jcrosstab(Education ~ Region, community)
#> Cross-Tabulation
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Education
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Crosstab: Education by Region
#> Education                  1: North    2: South    3: East    4: West     Total
#> -----------------------    --------    --------    -------    -------    ------
#> 1: Some high school           4           6          7          6         23
#>   (Row %)                    17.4%       26.1%      30.4%      26.1%     100.0%
#> 
#> 2: High school graduate       7           2          6          3         18
#>   (Row %)                    38.9%       11.1%      33.3%      16.7%     100.0%
#> 
#> 3: Some college               4           8          8          5         25
#>   (Row %)                    16.0%       32.0%      32.0%      20.0%     100.0%
#> 
#> 4: Bachelor's degree          6           2          2          3         13
#>   (Row %)                    46.2%       15.4%      15.4%      23.1%     100.0%
#> 
#> 5: Graduate degree            5           1          6          6         18
#>   (Row %)                    27.8%        5.6%      33.3%      33.3%     100.0%
#> 
#> Total                        26          19         29         23         97
#> 
jplot(ct, which = "stacked")


# Using juse() default (omit the data frame in either form)
juse(community)
#> Default data frame set to: community
jplot(WellbeingScore ~ Income)               # scatter
#> Scatterplot: WellbeingScore and Income
#> Using default data frame: community
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(WellbeingScore ~ Income, line = "lm")  # + regression line
#> Scatterplot: WellbeingScore and Income
#> Using default data frame: community
#> 
#> Analysis N: 97 (6 Excluded)
#> 

jplot(Age)                                   # histogram
#> Histogram: Age
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 

jplot(Region, Volunteer)                     # grouped bar chart
#> Grouped Bar Chart: Region and Volunteer
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 

```
