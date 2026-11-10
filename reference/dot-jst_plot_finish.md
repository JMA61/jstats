# Internal helper: mark a chart as jplot()'s, with the frame's facts

The class "jst_plot" ahead of ggplot2's, so the chart is still a ggplot
(`p + ggplot2::theme()` works) and jtable() knows it from a chart drawn
by hand (the S412 audit's F6, Session 413), and an attribute with what a
figure frame needs: the kind of chart, its N (the cases it draws; the
S412 audit's F7), its default title (ruling R69), its data for the Excel
sheet (ruling R65), the variables it names by name or by code where no
label stood (ruling R72), the scales that carry its colors and the look
it was drawn in.

## Usage

``` r
.jst_plot_finish(
  p,
  kind,
  n = NA_integer_,
  title = NA_character_,
  data = NULL,
  names_shown = character(0),
  codes_shown = list(),
  scales = list(),
  labelled = FALSE,
  look = NULL,
  tweak = NULL,
  filter = NULL,
  data_name = NULL,
  rerun = "chart",
  code_labels = list(),
  flip = FALSE,
  item_ns = NULL,
  relook = NULL
)
```

## Arguments

- p:

  The ggplot.

- kind:

  Character(1).

- n:

  The N, or NA.

- title:

  Character(1), the default title (labels, never the chart's kind), or
  NA.

- data:

  A data frame of what the chart shows, or NULL.

- names_shown:

  Character; variables the chart names by name, having no label.

- codes_shown:

  A named list: by variable, the codes shown with no label.

- scales:

  A list of list(aes, levels, guide): the color scales.

- labelled:

  Logical(1); TRUE when any variable the chart shows carries a label.

- look:

  The look it was drawn in.

- tweak:

  NULL, or a theme setting of the chart's own (the heatmap's slanted
  axis text), added again when the chart is drawn in another look.

- filter:

  NULL, or the filters it was drawn under
  ([`.jst_plot_filter_facts()`](https://jma61.github.io/jstats/reference/dot-jst_plot_filter_facts.md)),
  for the figure's note.

- data_name:

  The data frame's name as typed, or NULL: the frame ruling R72's note
  names in its jrelabel() line.

- rerun:

  What ruling R72's note asks for once labels are added: "chart" (draw
  it again) or "analysis" (run the analysis and draw it).

- code_labels:

  By variable of `codes_shown`, the codes it does label (code = label),
  for the note's jrelabel() line.

- flip:

  TRUE for a chart whose bars run across, whose theme is turned with
  them
  ([`.jst_plot_theme()`](https://jma61.github.io/jstats/reference/dot-jst_plot_theme.md)).

- item_ns:

  NULL, or the lowest and highest N of a set of items whose Ns differ,
  for the figure's note (ruling R68).

## Value

The chart.
