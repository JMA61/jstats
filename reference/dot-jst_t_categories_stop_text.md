# Internal: jt()'s stop for a grouping variable of more than 2 categories

"'g' has 4 categories." / "A t-test requires exactly 2." / "Use jaov()
for more than 2 categories." (Session 338). A text grouping variable's
blank cells are a category of their own, `<blank>` (Session 340), and
the stop did not say so: a "Male"/"Female" variable with empty cells
read "'Gender' has 3 categories" and was pointed to jaov(), with nothing
to say what the third category was or how to leave it out (Session 389,
Fix Slate 28; found putting ruling R34, under which a sheet's empty text
cells are `<blank>` as a CSV file's are). With `<blank>` among the
categories the stop names them, the blank last, and, when the categories
besides the blank are two, gives the declaration that leaves the blank
cells out before the jaov() line. The declaration names the values the
variable already declares as well
([`.jst_text_declare_args()`](https://jma61.github.io/jstats/reference/dot-jst_text_declare_args.md)),
since a declaration replaces them. No declaration line for a factor,
which jdeclare_missing() refuses, for data given as an expression, which
it cannot change, past a text variable's three declared values, or when
three or more categories would remain, where the line would lead to this
stop again (ruling R23). Without a `<blank>` category the stop is as it
was.

## Usage

``` r
.jst_t_categories_stop_text(has, lv, col, group_name, data_name, data_kind)
```

## Arguments

- has:

  Character(1); the count line, "'g' has 4 categories".

- lv:

  Character; the categories, the analysis factor's levels.

- col:

  The grouping variable as the user's data frame holds it, or NULL when
  it is not a column of that data frame.

- group_name, data_name:

  Character(1); the variable, and the data frame as the call names it.

- data_kind:

  What the call gave as its data
  ([`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)).

## Value

Character(1); the stop's text.
