# Internal helper: the regression or logistic table from one or more models

The models of one outcome side by side, in the order given (the
reference, Part 2.4). The columns are the style's, repeated per model
under a spanner reading "Model 1", "Model 2", ... or the list's names,
with columns.last added to the last model only; the Constant first
(intercept = yes); then the predictors in first-appearance order over
the models, a term's row labelled by its variable label; a dummy-coded
variable of three or more categories as its label row with the
categories indented under it, each named by its value label (its code
where it has none), and a two-category one as one row, "label:
category"; the reference category after the label (reference = row), in
the general note (note) or nowhere (none); then the fit rows the style
asks for, each under its model's first column, with the N row added when
the models' Ns differ (Session 401). Numbers follow the style: b, SE and
a confidence limit with a near-zero value kept visible
([`.jst_tbl_coef()`](https://jma61.github.io/jstats/reference/dot-jst_tbl_coef.md)),
a standardized coefficient, R2 and p at the decimals with APA's
leading-zero rule, counts whole. The general note: N where n.position
puts it, the reference categories under reference = note, the beta\*
definition when the column is shown, then the user's text; stars' legend
when p.format uses them. Under p.format = stars a model shown with b has
no p column, the asterisks on b (ruling R83, Session 419). Models with
different Ns are built, never stopped: the table says so – under
n.position = none too (ruling R84) – and the console gets the
jcomplete() line (the structure's `messages`, which jtable() prints).

## Usage

``` r
.jst_table_build_models(
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

  A list of jst_lm, or of jst_logistic, results; names are the model
  heads.

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
prints before the preview).
