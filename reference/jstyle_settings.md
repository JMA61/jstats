# The settings of a table style

Every setting a jstats table style holds: the general settings, which
set the look of every table, then one section per table type, which set
that table's columns, labels and notes. A style file (see
[`jstyle`](https://jma61.github.io/jstats/reference/jstyle.md)) sets any
of them; a setting it leaves out comes from the style its based.on line
names, and in the end from the built-in apa style, whose value each
entry gives – with the built-in report style's where it differs. A table
type's setting can also be given in a
[`jtable`](https://jma61.github.io/jstats/reference/jtable.md) call, for
that table only.

This page is made from the list jstats checks every style against, so it
names exactly what jstats accepts. A Greek letter in a label is written
in a style file as the letter itself; this page names it.

## See also

[`jstyle`](https://jma61.github.io/jstats/reference/jstyle.md) to list,
print and copy styles;
[`jtable`](https://jma61.github.io/jstats/reference/jtable.md) for the
tables.

## In a style file

A setting is its name, an equals sign and a value; a list of values is
separated by commas; a `#` starts a note. The general settings come
first, then each table type's under its heading:


    based.on = apa
    font     = Arial

    [regression]
    fit.rows = r2, n

A general setting may also be set in a table type's section, for that
table type only.

## General settings

- `font`:

  the typeface of every cell, caption and note. Takes any text. In apa:
  `Times New Roman`; in report: `Arial`.

- `size`:

  the text size, in points. Takes a number from 6 to 72. In apa: `12`;
  in report: `10`.

- `paper`:

  the page the file opens on: a4 \| letter. Takes one of a4 \| letter.
  In apa: `a4`.

- `caption.form`:

  apa: bold "Table 1", the italic title on the next line \| journal:
  bold "Table 1." and the title on one line \| report: "Table 1:" and
  the title. Takes one of apa \| journal \| report. In apa: `apa`; in
  report: `report`.

- `caption.position`:

  row: the table's first row, repeated with the header on a new page \|
  paragraph: above the table. Takes one of row \| paragraph. In apa:
  `row`.

- `caption.size`:

  the caption's text size, in points. Takes a number from 6 to 72. In
  apa: `12`; in report: `10`.

- `caption.fill`:

  a color filling the caption row (caption.position = row), header for
  the header's fill and text color, or none. Takes a color name such as
  lightblue, or six hex digits such as ADD8E6; or header, or none. In
  apa: `none`.

- `header.fill`:

  a color filling the header cells, or none. Takes a color name such as
  lightblue, or six hex digits such as ADD8E6; or none. In apa: `none`;
  in report: `D9D9D9`.

- `header.text`:

  the color of the header's text. Takes a color name such as lightblue,
  or six hex digits such as ADD8E6. In apa: `000000`.

- `header.bold`:

  bold header text: yes \| no. Takes one of yes \| no. In apa: `no`; in
  report: `yes`.

- `band.fill`:

  a color filling every other data row, or none. Takes a color name such
  as lightblue, or six hex digits such as ADD8E6; or none. In apa:
  `none`.

- `heading.fill`:

  a color filling each variable's label row (the rows variable.headings
  sets), or none. Takes a color name such as lightblue, or six hex
  digits such as ADD8E6; or none. In apa: `none`.

- `rules`:

  apa: rules above and below the header and under the table \| grid:
  every cell \| outer: a box \| none. Takes one of apa \| grid \| outer
  \| none. In apa: `apa`.

- `rule.color`:

  the color of the rules. Takes a color name such as lightblue, or six
  hex digits such as ADD8E6. In apa: `000000`.

- `note.label`:

  the word the general note opens on: Note. \| Notes: \| Source:. Takes
  any text, or nothing. In apa: `Note.`; in report: `Note:`.

- `note.label.italic`:

  the note's label in italics, as APA sets it: yes \| no. Takes one of
  yes \| no. In apa: `yes`; in report: `no`.

- `note.position`:

  row: the table's last row \| paragraph: under the table. Takes one of
  row \| paragraph. In apa: `row`.

- `note.size`:

  the notes' text size, in points. Takes a number from 6 to 72. In apa:
  `12`; in report: `9`.

- `n.position`:

  where N, the number of cases, goes: note (the general note opens on
  it) \| title ("(N = 103)" after the title) \| none. Takes one of note
  \| title \| none. In apa: `note`.

- `decimals`:

  the decimal places of a statistic, such as a mean. Takes a whole
  number from 0 to 6. In apa: `2`.

- `leading.zero`:

  the zero before the point: no drops it on a statistic that cannot
  exceed 1, such as p (.23) \| yes keeps it (0.23) \| never drops it on
  every number below 1 (.197 for an SE). Takes one of yes \| no \|
  never. In apa: `no`; in report: `yes`.

- `p.format`:

  exact: the p-value \| stars: asterisks \| both. Takes one of exact \|
  stars \| both. In apa: `exact`.

- `p.decimals`:

  the decimal places of a p-value. Takes a whole number from 1 to 6. In
  apa: `3`.

- `stars`:

  the p-values the asterisks mark, largest first. Takes one to three
  p-values between 0 and 1, largest first. In apa: `.05, .01, .001`.

- `marks`:

  the marks of the notes on rows: letters (a, b, c) \| symbols
  (daggers). Takes one of letters \| symbols. In apa: `letters`.

- `minus`:

  true: a true minus sign \| hyphen: the keyboard's hyphen. Takes one of
  true \| hyphen. In apa: `true`.

- `thousands`:

  comma: 1,037 \| none: 1037. Takes one of comma \| none. In apa:
  `comma`.

- `landscape`:

  auto: a landscape page when the table is wider than a portrait one \|
  yes \| no. Takes one of auto \| yes \| no. In apa: `auto`.

- `line.spacing`:

  single \| double. Takes one of single \| double. In apa: `single`.

- `percent.decimals`:

  the decimal places of a percentage. Takes a whole number from 0 to 4.
  In apa: `1`.

- `filter.note`:

  yes: the general note says which cases a filter kept (jsubset(),
  subset =) \| no. Takes one of yes \| no. In apa: `yes`.

## \[descriptives\]: a descriptives table

- `title`:

  the title when the call gives none. Takes any text. In apa:
  `Descriptive Statistics`.

- `columns`:

  the columns, in order: n, mean, sd, min, max. Takes one or more of n,
  mean, sd, min, max, in order, separated by commas. In apa:
  `n, mean, sd, min, max`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `mean.label`:

  the head of the mean column. Takes any text, or nothing. In apa: `M`.

- `sd.label`:

  the head of the sd column. Takes any text, or nothing. In apa: `SD`.

- `min.label`:

  the head of the min column. Takes any text, or nothing. In apa: `Min`.

- `max.label`:

  the head of the max column. Takes any text, or nothing. In apa: `Max`.

- `group.headings`:

  how a heading from headings = is set: italic \| bold \| plain. Takes
  one of italic \| bold \| plain. In apa: `italic`.

## \[frequencies\]: a frequency table

- `title`:

  the title when the call gives none. Takes any text. In apa:
  `Frequency Distributions`.

- `columns`:

  the columns, in order: n, percent (of all cases), valid.percent,
  cumulative. Takes one or more of n, percent, valid.percent,
  cumulative, in order, separated by commas. In apa: `n, percent`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `percent.label`:

  the head of the percent column. Takes any text, or nothing. In apa:
  `%`.

- `valid.percent.label`:

  the head of the valid.percent column. Takes any text, or nothing. In
  apa: `Valid %`.

- `cumulative.label`:

  the head of the cumulative column. Takes any text, or nothing. In apa:
  `Cumulative %`.

- `missing.rows`:

  a variable's missing cases: combined (one row) \| each (a row per
  missing value) \| none. Takes one of combined \| each \| none. In apa:
  `combined`.

- `missing.label`:

  the label of the combined missing row. Takes any text. In apa:
  `Missing`.

- `variable.headings`:

  how each variable's label row is set: plain \| italic \| bold. Takes
  one of plain \| italic \| bold. In apa: `plain`; in report: `bold`.

- `group.headings`:

  how a heading from headings = is set: italic \| bold \| plain. Takes
  one of italic \| bold \| plain. In apa: `italic`.

## \[regression\]: a regression table

- `title`:

  the title when the call gives none; {outcome} is the outcome's label.
  Takes any text. In apa:
  `Regression Coefficients Predicting {outcome}`.

- `columns`:

  the columns of each model, in order: b, se, beta, p, t, ci,
  beta.gelman (Gelman's standardized coefficient). Takes one or more of
  b, se, beta, p, t, ci, beta.gelman, in order, separated by commas. In
  apa: `b, se, beta, p`.

- `columns.last`:

  columns added to the last model only, or none. Takes one or more of b,
  se, beta, p, t, ci, beta.gelman, in order, separated by commas; or
  none. In apa: `none`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Predictor`.

- `b.label`:

  the head of the b column. Takes any text, or nothing. In apa: `b`.

- `se.label`:

  the head of the se column. Takes any text, or nothing. In apa: `SE`.

- `beta.label`:

  the head of the beta column. Takes any text, or nothing. In apa:
  \\\beta\\.

- `p.label`:

  the head of the p column. Takes any text, or nothing. In apa: `p`.

- `t.label`:

  the head of the t column. Takes any text, or nothing. In apa: `t`.

- `ci.label`:

  the head of the ci column. Takes any text, or nothing. In apa:
  `95% CI`.

- `beta.gelman.label`:

  the head of the beta.gelman column. Takes any text, or nothing. In
  apa: \\\beta\\\*.

- `ci.style`:

  one: the interval in one column, \[LL, UL\] \| two: LL and UL. Takes
  one of one \| two. In apa: `one`.

- `intercept`:

  the constant's row, first in the table: yes \| no. Takes one of yes \|
  no. In apa: `yes`.

- `intercept.label`:

  the constant's row label. Takes any text. In apa: `Constant`.

- `fit.rows`:

  the fit rows under the predictors, in order: r2, adj.r2, f, delta.r2
  (nested models), f.change (its F test), n, or none. Takes one or more
  of r2, adj.r2, f, delta.r2, f.change, n, in order, separated by
  commas; or none. In apa: `r2`.

- `reference`:

  where a dummy-coded variable's reference category is named: row (after
  its label) \| note (the general note) \| none. Takes one of row \|
  note \| none. In apa: `row`.

- `reference.label`:

  the word before the reference category: reference \| ref. Takes any
  text. In apa: `reference`.

- `variable.headings`:

  how a dummy-coded variable's label row is set: plain \| italic \|
  bold. Takes one of plain \| italic \| bold. In apa: `plain`; in
  report: `bold`.

- `group.headings`:

  how a heading row is set: italic \| bold \| plain. Takes one of italic
  \| bold \| plain. In apa: `italic`.

## \[logistic\]: a logistic regression table

- `title`:

  the title when the call gives none; {outcome} is the outcome's label.
  Takes any text. In apa:
  `Logistic Regression Coefficients Predicting {outcome}`.

- `columns`:

  the columns of each model, in order: b, se, or (the odds ratio), p,
  wald, ci (for the odds ratio), beta.gelman. Takes one or more of b,
  se, or, p, wald, ci, beta.gelman, in order, separated by commas. In
  apa: `b, se, or, p`.

- `columns.last`:

  columns added to the last model only, or none. Takes one or more of b,
  se, or, p, wald, ci, beta.gelman, in order, separated by commas; or
  none. In apa: `none`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Predictor`.

- `b.label`:

  the head of the b column. Takes any text, or nothing. In apa: `b`.

- `se.label`:

  the head of the se column. Takes any text, or nothing. In apa: `SE`.

- `or.label`:

  the head of the or column. Takes any text, or nothing. In apa: `OR`.

- `p.label`:

  the head of the p column. Takes any text, or nothing. In apa: `p`.

- `wald.label`:

  the head of the wald column. Takes any text, or nothing. In apa:
  `Wald`.

- `ci.label`:

  the head of the ci column. Takes any text, or nothing. In apa:
  `95% CI for OR`.

- `beta.gelman.label`:

  the head of the beta.gelman column. Takes any text, or nothing. In
  apa: \\\beta\\\*.

- `ci.style`:

  one: the interval in one column, \[LL, UL\] \| two: LL and UL. Takes
  one of one \| two. In apa: `one`.

- `intercept`:

  the constant's row, first in the table: yes \| no. Takes one of yes \|
  no. In apa: `yes`.

- `intercept.label`:

  the constant's row label. Takes any text. In apa: `Constant`.

- `fit.rows`:

  the fit rows under the predictors, in order: chisq (the model
  chi-square), nagelkerke, cox.snell, neg2ll, aic, n, or none. Takes one
  or more of chisq, nagelkerke, cox.snell, neg2ll, aic, n, in order,
  separated by commas; or none. In apa: `chisq, nagelkerke`.

- `reference`:

  where a dummy-coded variable's reference category is named: row (after
  its label) \| note (the general note) \| none. Takes one of row \|
  note \| none. In apa: `row`.

- `reference.label`:

  the word before the reference category: reference \| ref. Takes any
  text. In apa: `reference`.

- `variable.headings`:

  how a dummy-coded variable's label row is set: plain \| italic \|
  bold. Takes one of plain \| italic \| bold. In apa: `plain`; in
  report: `bold`.

- `group.headings`:

  how a heading row is set: italic \| bold \| plain. Takes one of italic
  \| bold \| plain. In apa: `italic`.

## \[correlation\]: a correlation table

- `title`:

  the title when the call gives none. Takes any text. In apa:
  `Descriptive Statistics and Correlations for Study Variables`.

- `columns`:

  the columns before the correlations, in order: n, mean, sd, or none.
  Takes one or more of n, mean, sd, in order, separated by commas; or
  none. In apa: `n, mean, sd`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `mean.label`:

  the head of the mean column. Takes any text, or nothing. In apa: `M`.

- `sd.label`:

  the head of the sd column. Takes any text, or nothing. In apa: `SD`.

- `lower.triangle`:

  yes: each correlation once, below the diagonal \| no: both triangles.
  Takes one of yes \| no. In apa: `yes`.

- `r.stars`:

  yes: asterisks on each correlation for its p-value, explained under
  the table \| no. Takes one of yes \| no. In apa: `yes`.

- `method.note`:

  yes: the note names a Spearman or Kendall table's correlations \| no.
  Takes one of yes \| no. In apa: `yes`.

## \[ttest\]: a t-test table

- `title`:

  the title when the call gives none; {group} is the grouping variable's
  label. Takes any text. In apa:
  `Means, Standard Deviations, and t Tests by {group}`.

- `columns`:

  the columns, in order: each group's n, mean and sd, then t (with its
  df), p, d (Cohen's d), diff (the mean difference) and ci (its
  confidence interval). Takes one or more of n, mean, sd, t, p, d, diff,
  ci, in order, separated by commas. In apa: `mean, sd, t, p, d`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `mean.label`:

  the head of the mean column. Takes any text, or nothing. In apa: `M`.

- `sd.label`:

  the head of the sd column. Takes any text, or nothing. In apa: `SD`.

- `t.label`:

  the head of the t column. Takes any text, or nothing. In apa: `t`.

- `df.label`:

  the head of the df column, when the tests' df differ. Takes any text,
  or nothing. In apa: `df`.

- `p.label`:

  the head of the p column. Takes any text, or nothing. In apa: `p`.

- `d.label`:

  the head of the d column. Takes any text, or nothing. In apa: `d`.

- `diff.label`:

  the head of the diff column. Takes any text, or nothing. In apa:
  `Mean difference`.

- `ci.label`:

  the head of the ci column. Takes any text, or nothing. In apa:
  `95% CI`.

- `ci.style`:

  one: the interval in one column, \[LL, UL\] \| two: LL and UL. Takes
  one of one \| two. In apa: `one`.

- `group.spanner`:

  yes: the grouping variable's label over the groups' columns \| no.
  Takes one of yes \| no. In apa: `yes`.

- `test.note`:

  yes: the note says when a test is Welch's or a paired test \| no.
  Takes one of yes \| no. In apa: `yes`.

## \[anova\]: an ANOVA table

- `title`:

  the title when the call gives none; {group} is the grouping variable's
  label. Takes any text. In apa:
  `Means, Standard Deviations, and One-Way Analyses of Variance by {group}`.

- `columns`:

  the columns, in order: each group's n, mean and sd, then f (with its
  df), p, eta2. Takes one or more of n, mean, sd, f, p, eta2, in order,
  separated by commas. In apa: `mean, sd, f, p, eta2`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `mean.label`:

  the head of the mean column. Takes any text, or nothing. In apa: `M`.

- `sd.label`:

  the head of the sd column. Takes any text, or nothing. In apa: `SD`.

- `f.label`:

  the head of the f column. Takes any text, or nothing. In apa: `F`.

- `df.label`:

  the head of the df column, when the tests' df differ. Takes any text,
  or nothing. In apa: `df`.

- `p.label`:

  the head of the p column. Takes any text, or nothing. In apa: `p`.

- `eta2.label`:

  the head of the eta2 column. Takes any text, or nothing. In apa:
  \\\eta^2\\.

- `group.spanner`:

  yes: the grouping variable's label over the groups' columns \| no.
  Takes one of yes \| no. In apa: `yes`.

- `test.note`:

  yes: the note says when a test is Welch's \| no. Takes one of yes \|
  no. In apa: `yes`.

## \[crosstab\]: a crosstab

- `title`:

  the title when the call gives none; {group} is the column variable's
  label. Takes any text. In apa:
  `Frequencies and Percentages by {group}`.

- `columns`:

  each group's columns, in order: n, percent. Takes one or more of n,
  percent, in order, separated by commas. In apa: `n, percent`.

- `total`:

  yes: a Total column after the groups \| no. Takes one of yes \| no. In
  apa: `yes`.

- `percent.base`:

  what a percentage is of: column (each group's cases) \| row (each
  category's) \| total (all cases). Takes one of column \| row \| total.
  In apa: `column`.

- `test.columns`:

  the chi-square test's columns on each variable's row, in order: chisq,
  df, p, v (Cramer's V), or none. Takes one or more of chisq, df, p, v,
  in order, separated by commas; or none. In apa: `chisq, df, p, v`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa:
  `Variable`.

- `n.label`:

  the head of the n column. Takes any text, or nothing. In apa: `n`.

- `percent.label`:

  the head of the percent column. Takes any text, or nothing. In apa:
  `%`.

- `total.label`:

  the head over the Total column. Takes any text. In apa: `Total`.

- `chisq.label`:

  the head of the chisq column. Takes any text, or nothing. In apa:
  \\\chi^2\\.

- `df.label`:

  the head of the df column. Takes any text, or nothing. In apa: `df`.

- `p.label`:

  the head of the p column. Takes any text, or nothing. In apa: `p`.

- `v.label`:

  the head of the v column. Takes any text, or nothing. In apa: `V`.

- `group.spanner`:

  yes: the column variable's label over the groups' columns \| no. Takes
  one of yes \| no. In apa: `yes`.

- `variable.headings`:

  how each variable's label row is set: plain \| italic \| bold. Takes
  one of plain \| italic \| bold. In apa: `plain`; in report: `bold`.

## \[reliability\]: a reliability table

- `title`:

  the title when the call gives none. Takes any text. In apa:
  `Item Statistics and Reliability`.

- `columns`:

  the columns, in order: mean, sd, item.total (the corrected item-total
  correlation), alpha.if.deleted. Takes one or more of mean, sd,
  item.total, alpha.if.deleted, in order, separated by commas. In apa:
  `mean, sd, item.total, alpha.if.deleted`.

- `stub.label`:

  the first column's head. Takes any text, or nothing. In apa: `Item`.

- `mean.label`:

  the head of the mean column. Takes any text, or nothing. In apa: `M`.

- `sd.label`:

  the head of the sd column. Takes any text, or nothing. In apa: `SD`.

- `item.total.label`:

  the head of the item.total column; \*r\* sets r in italics. Takes any
  text, or nothing. In apa: `Item-total *r*`.

- `alpha.if.deleted.label`:

  the head of the alpha.if.deleted column. Takes any text, or nothing.
  In apa: \\\alpha\\ if item deleted.

- `alpha`:

  yes: Cronbach's alpha in the note, or after each scale's name when the
  table holds several \| no. Takes one of yes \| no. In apa: `yes`.

- `item.total.note`:

  yes: the note says what the item.total column is \| no. Takes one of
  yes \| no. In apa: `yes`.

- `group.headings`:

  how a scale's name row is set: italic \| bold \| plain. Takes one of
  italic \| bold \| plain. In apa: `italic`.
