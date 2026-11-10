# Internal helper: jtable() given charts alone

Each chart made a figure (ruling R63, Session 411): in the call's style
when it names one – the chart drawn again in that style's look (the S412
audit's F6) – else in the style it was drawn in. The call's title, note
and source make one figure's, so a call of several charts takes none of
them; a table's own inputs – headings, markers, a table type's settings
– a chart takes none of (Session 415). Ruling R72's note for each figure
that shows a name or a code; then the report, and the file.

## Usage

``` r
.jst_figure_call(
  charts,
  x_sub,
  style,
  title,
  note,
  source,
  given,
  over_q,
  landscape,
  out_path,
  overwrite,
  open,
  print,
  cl,
  mc
)
```

## Arguments

- charts:

  The charts, a list.

- x_sub:

  The call's first argument as typed.

- style:

  The call's style, resolved, or NULL.

- title, note, source:

  As [`jtable()`](https://jma61.github.io/jstats/reference/jtable.md)'s.

- given:

  Logical, named headings and markers: which the call gave.

- over_q:

  The call's style settings, as typed.

- landscape:

  NULL, or the call's page setting, checked.

- out_path, overwrite, open, print:

  As
  [`.jst_table_finish()`](https://jma61.github.io/jstats/reference/dot-jst_table_finish.md).

- cl, mc:

  The call and the matched call.

## Value

The figure, or the figures together (class "jst_tables"), invisibly.
