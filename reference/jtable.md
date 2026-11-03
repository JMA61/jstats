# Make a publication table from a saved result

`jtable()` turns a saved analysis result into a publication table: it
prints a preview in the console and, when `file` is given, writes the
table to a Word file (.docx) that opens in Word, LibreOffice and Google
Docs. The table's look and conventions come from a style – the built-in
`"apa"` style, or a style file of your own (see
[`jstyle()`](https://jma61.github.io/jstats/reference/jstyle.md)); the
preview is a facsimile of the Word table, so what prints is what the
file holds.

## Usage

``` r
jtable(
  x,
  headings = NULL,
  markers = NULL,
  title = NULL,
  note = NULL,
  file = NULL,
  style = NULL,
  overwrite = FALSE,
  open = FALSE,
  print = NULL,
  ...
)

# S3 method for class 'jst_table'
print(x, ...)
```

## Arguments

- x:

  A saved result – what an analysis function returns, kept with `<-` –
  or a list of them. Results share a table when they share its columns:
  a list of
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md)
  results, or of
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)
  results, stacks into one table, each result's variables under its name
  in the list when the list is named; a list of
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) results, or
  of
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
  results, with one outcome puts the models side by side, headed "Model
  1", "Model 2", ... or by the list's names; a list of
  [`jt()`](https://jma61.github.io/jstats/reference/jt.md),
  [`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) or
  [`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
  results with one grouping variable stacks a row or a block per
  outcome; a list of
  [`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md)
  results stacks the scales, each under its name. A
  [`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) result
  is a table of its own. A table `jtable()` has already built, or a list
  of them, goes to the file as it is, the tables in the order given and
  numbered so.

- headings:

  A named list: each heading and the variables under it, bare or in
  quotes, e.g.
  `list("Dependent variable" = Wellbeing, "Independent variables" = c(Income, Age))`.
  Every variable of the result goes under one heading; the table follows
  the list's order. For a descriptives or frequency table.

- markers:

  A named list: each specific note's text and the variables it marks,
  e.g. `list("Mean-centered" = c(Income, Age))`. The style assigns the
  marks (superscript letters under APA), sets each on its rows' labels,
  and writes the note under the table. In a regression table a
  predictor's row is marked; in a t-test or ANOVA table an outcome's; in
  a crosstab a variable's label row; in a reliability table an item's.

- title:

  The table's title; the style's title when NULL (a regression table's
  names the outcome, a t-test, ANOVA or crosstab's the grouping
  variable). `*text*` sets a word in italics.

- note:

  The general note's text, after what the style writes there (N, a
  reference category); `*text*` sets a word in italics. NULL for none.

- file:

  The Word file to write, with its .docx extension: a bare name goes in
  the output folder (`joptions(output.dir = )`) or the working
  directory; a path with a folder goes there. NULL writes nothing.

- style:

  The style's name in quotes: `"apa"`, or the name of a style file
  (`"myjournal"` for myjournal.jstyle), looked for in the style folder
  (`joptions(style.dir = )`), the working directory and your jstats
  folder; or a path to one. NULL (the default) uses
  `joptions(style = )`, apa when it is not set.

- overwrite:

  Logical. Replace a file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

- open:

  Logical. TRUE opens the file once it is written, in the program your
  computer opens .docx files with; only in an interactive session, so a
  script or a rendered page opens nothing. Needs `file`.

- print:

  Print the preview? NULL (the default) follows the
  [`joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  level: the preview prints unless the level is `"silent"`. TRUE prints
  it under any level; FALSE prints nothing and writes the file alone.

- ...:

  A setting of the table type's section of the style, for this table
  only, e.g. `columns = c("mean", "sd")` for a descriptives table,
  `missing.rows = "none"` for a frequency table or
  `fit.rows = c("r2", "delta.r2")` for a regression table: the call
  outranks the style file. The general settings (the font, the caption's
  form, the decimals) are the style file's, except `landscape = "yes"`
  or `"no"`, a page choice the call may make. Any other input stops with
  "unused input".

## Value

The table, invisibly: an object of class `jst_table`, which prints its
preview when typed.

## Details

A table is made from each kind of result: a descriptives table from one
or more [`jdesc`](https://jma61.github.io/jstats/reference/jdesc.md)
results; a frequency table from one or more
[`jfreq`](https://jma61.github.io/jstats/reference/jfreq.md) results –
each variable's label on a row of its own, its categories indented under
it; a regression table from one or more
[`jlm`](https://jma61.github.io/jstats/reference/jlm.md) results, or a
logistic regression table from
[`jlogistic`](https://jma61.github.io/jstats/reference/jlogistic.md)
results – the models of one outcome side by side, each under its own
head, the constant first, a dummy-coded variable's categories indented
under its label with the reference category named, and the fit rows
under the predictors; a correlation table from a
[`jcorr`](https://jma61.github.io/jstats/reference/jcorr.md) result –
the variables numbered, their n, mean and standard deviation, and the
correlations below the diagonal; a t-test table from
[`jt`](https://jma61.github.io/jstats/reference/jt.md) results, or an
ANOVA table from
[`jaov`](https://jma61.github.io/jstats/reference/jaov.md) results, of
one grouping variable – one row per outcome, each group's mean and
standard deviation, then the test; a crosstab from
[`jcrosstab`](https://jma61.github.io/jstats/reference/jcrosstab.md)
results of one column variable – each row variable's categories with
their counts and percentages in each group, and the chi-square test; and
a reliability table from
[`jalpha`](https://jma61.github.io/jstats/reference/jalpha.md) results –
each item's mean, standard deviation, corrected item-total correlation
and alpha if the item is deleted. The variables of a descriptives or
frequency table go under role headings when `headings` names them, and
each specific note's variables are marked when `markers` names them. A
filter the analysis applied
([`jsubset`](https://jma61.github.io/jstats/reference/jsubset.md),
`subset =`) is named in the general note.
