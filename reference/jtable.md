# Make a publication table from a saved result

`jtable()` turns a saved analysis result into a publication table and,
when `file` is given, writes it to a Word file (.docx) that opens in
Word, LibreOffice and Google Docs. The table's look and conventions come
from a style – the built-in `"apa"` style for a journal, the built-in
`"report"` style for a report, or a style file of your own (see
[`jstyle`](https://jma61.github.io/jstats/reference/jstyle.md)).

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

# S3 method for class 'jst_tables'
print(x, ...)
```

## Arguments

- x:

  A saved result – what an analysis function returns, kept with `<-` –
  or a list of them that share one table: a list of
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
  is a table of its own. Or a table `jtable()` has already built, or a
  list of them: they go to the file as they are, in the order given.

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

  The style's name in quotes: `"apa"`, `"report"`, or the name of a
  style file (`"myjournal"` for myjournal.jstyle), looked for in the
  style folder (`joptions(style.dir = )`), the working directory and
  your jstats folder; or a path to one. NULL (the default) uses
  `joptions(style = )`, apa when it is not set.

- overwrite:

  Logical. Replace a file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

- open:

  Logical. TRUE opens the file once it is written, in the program your
  computer opens .docx files with; only in an interactive session, so a
  script or a rendered page opens nothing. Needs `file`.

- print:

  Print the report of what was made? NULL (the default) follows the
  [`joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  level: the report prints unless the level is `"silent"`. TRUE prints
  it under any level; FALSE prints nothing.

- ...:

  A setting of the table type's section of the style, for this table
  only, e.g. `columns = c("mean", "sd")` for a descriptives table,
  `missing.rows = "none"` for a frequency table or
  `fit.rows = c("r2", "delta.r2")` for a regression table: the call
  outranks the style file.
  [`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
  lists every setting. The general settings (the font, the caption's
  form, the decimals) are the style file's, except `landscape = "yes"`
  or `"no"`, a page choice the call may make. Any other input stops with
  "unused input".

## Value

The table, invisibly: an object of class `jst_table`, which shows a
facsimile of the Word table when printed. A call given two or more built
tables returns them together (class `jst_tables`), which prints each
one, numbered as in the file.

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

**One call, one table.** The results given to one call make one table:
results share a table when they share its columns (see `x`). Results
that cannot share one – results of different kinds, models of different
outcomes, tests of different grouping variables – stop, and the message
gives the lines that make each table in a call of its own. To put
several tables in one file, build each table, then give the tables
together: `jtable(list(t1, t2, t3), file = "Tables.docx")`. The tables
keep the order given and are numbered so.

**What prints.** `jtable()` reports what it made: each table's number
and title, what it holds, the page it is on (a landscape page, the text
stepped down to fit), and where the file was written. To see a table in
the console, keep it with `<-` and print it: `print(t1)`, or type `t1`.
The console shows a facsimile of the Word table, its numbers formatted
by the style.

**The page.** Under the style's `landscape = "auto"` each table gets the
page it needs: a table too wide for a portrait page sits on landscape
pages of its own, and the tables around it stay portrait.
`landscape = "yes"` or `"no"` in the call that writes a file sets every
page.

**The analysis inside the call.** `jtable(jlm(Fear ~ Age, d))` runs the
analysis without printing it and makes its table; errors and warnings
still show.

**Keeping a result for a later session.** A saved result is an R object,
which base R keeps in a file of its own: `saveRDS(m1, "m1.rds")`, then
in a later session `m1 <- readRDS("m1.rds")`. A result made by an
earlier version of jstats than the table needs stops, and says which
version made it.

## See also

[`jstyle`](https://jma61.github.io/jstats/reference/jstyle.md) for
styles,
[`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
for every setting a style holds.

## Examples

``` r
# Keep a result, make its table, and look at it in the console
d1 <- jdesc(community, Age, Income, print = FALSE)
t1 <- jtable(d1, title = "Descriptive Statistics for Study Variables")
#> Table 1. Descriptive Statistics for Study Variables
#>   2 variables, on a portrait page.
#> No file was written.
#> 
print(t1)
#> Table 1
#> Descriptive Statistics for Study Variables
#> --------------------------------------------------------------
#> Variable              n       M          SD       Min     Max
#> --------------------------------------------------------------
#> Age (years)          103      40.65      11.62      18      71
#> Annual income (USD)   97  49,855.67  17,427.22  14,000  93,000
#> --------------------------------------------------------------
#> Note. N = 103.
#> 

# Two models of one outcome side by side, written to a Word file
m1 <- jlm(WellbeingScore ~ Age, community, print = FALSE)
m2 <- jlm(WellbeingScore ~ Age + Volunteer, community, print = FALSE)
t2 <- jtable(list(m1, m2), file = file.path(tempdir(), "Table2.docx"),
             overwrite = TRUE)
#> Table 1. Regression Coefficients Predicting Wellbeing score (0-100)
#>   2 models side by side, on a portrait page.
#> Table written to /tmp/RtmpEGS82R/Table2.docx
#> 

# Several tables in one file: build each, then give them together
doc <- jtable(list(t1, t2), file = file.path(tempdir(), "Tables.docx"),
              overwrite = TRUE)
#> Table 1. Descriptive Statistics for Study Variables
#>   2 variables, on a portrait page.
#> Table 2. Regression Coefficients Predicting Wellbeing score (0-100)
#>   2 models side by side, on a portrait page.
#> 2 tables written to /tmp/RtmpEGS82R/Tables.docx
#> 
print(doc)
#> Table 1
#> Descriptive Statistics for Study Variables
#> --------------------------------------------------------------
#> Variable              n       M          SD       Min     Max
#> --------------------------------------------------------------
#> Age (years)          103      40.65      11.62      18      71
#> Annual income (USD)   97  49,855.67  17,427.22  14,000  93,000
#> --------------------------------------------------------------
#> Note. N = 103.
#> 
#> Table 2
#> Regression Coefficients Predicting Wellbeing score (0-100)
#> --------------------------------------------------------------------------
#>                                   Model 1                  Model 2
#> Predictor                   b     SE    β     p      b     SE    β     p
#> --------------------------------------------------------------------------
#> Constant                  37.11  3.90       <.001  37.33  3.81       <.001
#> Age (years)                0.34  0.09  .34  <.001   0.27  0.09  .27   .005
#> Volunteered in past year                            5.36  2.18  .23   .016
#> R²                          .12                      .17
#> --------------------------------------------------------------------------
#> Note. N = 103.
#> 

# Keep a result for a later session with base R
path <- file.path(tempdir(), "m1.rds")
saveRDS(m1, path)
m1 <- readRDS(path)
```
