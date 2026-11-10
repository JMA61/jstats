# Internal helper: ruling R72's note, for a table or a figure that shows a name or a code

A jstats result keeps the labels it had when the analysis ran (ruling
R72, Session 412), so a table or a figure made from it shows a
variable's name, or a category's code, wherever the result holds no
label. Given once, when the table or the figure is made (the S412
audit's F9, Session 413): a consequential note when the result holds
labels for other variables, so the gap is likely an oversight; an
advisory note, at joutput("full"), when it holds none at all. The remedy
is the user's: jrelabel(), then the analysis – or the chart – run again;
the line given carries the user's own codes and never a label of
jstats's making ("..." where the label goes). jrelabel()'s labels =
replaces a variable's value labels, so a code line lists the labels the
result holds as well.

## Usage

``` r
.jst_label_gap_note(what, gaps)
```

## Arguments

- what:

  "Table 1" or "Figure 1".

- gaps:

  A list: names_shown, codes_shown, labelled, data_name, code_labels (by
  variable, the codes and labels the result holds: a named character
  vector, code = label) and, for a figure, rerun ("chart" or
  "analysis").

## Value

NULL when the note is not given at the output level in force, else the
note's text.
