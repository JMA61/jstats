# Internal helper: what a pie, a donut and a 100% stacked bar take

The front-door stops of the three kinds (rulings R66 and R68), before
anything is read. A pie or a donut shows ONE variable as ONE whole: two
or more variables stop, and so do by = and facet =, pointing to the 100%
stacked bar (the report manuals: several breakdowns as stacked bars, not
several pies). A 100% stacked bar takes a set of items, or one variable
and by =: an item named twice, facet =, and by = beside several
variables stop. The lines offered are generic examples: a line built
from the call could stop again on the variables it names.

## Usage

``` r
.jst_plot_whole_front(type, vars, by_name = NULL, facet_name = NULL)
```

## Arguments

- type:

  "pie", "donut" or "stacked".

- vars:

  Character; the variables.

- by_name, facet_name:

  Character(1) or NULL.

## Value

NULL, invisibly; or stops.
