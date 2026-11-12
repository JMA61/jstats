# Internal helper: the t-test or ANOVA table from one or more results

The results of one grouping variable, one row per outcome in the order
given; the columns are the style's: each group's columns (n, mean, sd)
under the group's value label (its code where it has none), the grouping
variable's label over them all (group.spanner), then the test's (t, p,
d, diff, ci; or f, p, eta2). Signs as jt() computes them, the first
group's mean minus the second's. The general note: the groups' ns under
n.position = note or title (a range per group where they vary; ruling
R59 keeps them out of the title), the filter, a sentence for a Welch or
a paired test (test.note), the user's text; the stars' legend when
p.format uses them. Under p.format = stars a table shown with its
statistic has no p column, the asterisks on t or F (ruling R83, Session
419).

## Usage

``` r
.jst_table_build_groups(
  results,
  style,
  headings = NULL,
  markers = NULL,
  title = NULL,
  note = NULL
)
```

## Arguments

- results:

  A list of jst_ttest, or of jst_anova, results.

- style:

  The style list.

- headings:

  A named list: each heading's variables (or NULL).

- markers:

  A named list: each specific note's variables (or NULL).

- title:

  The user's title, or NULL for the type's template.

- note:

  The user's general note, or NULL.

## Value

A jst_table, with a `messages` element (character; the notes jtable()
prints).
