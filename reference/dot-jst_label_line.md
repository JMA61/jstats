# Internal: the line that puts back a variable's label

Session 382 (Fix Slate 25). as.numeric() and as.Date() drop every
attribute, the variable label among them, so a conversion line jstats
offers is followed, where the variable has a label, by the line that
puts it back: `attr(d$v, "label") <- "..."`, the label escaped.
jload()'s as.numeric() lines
([`.jst_numeric_lines()`](https://jma61.github.io/jstats/reference/dot-jst_numeric_lines.md),
Session 381) and jscreen()'s as.Date() lines
([`.jst_date_text_report()`](https://jma61.github.io/jstats/reference/dot-jst_date_text_report.md))
share it.

## Usage

``` r
.jst_label_line(v, label)
```

## Arguments

- v:

  The variable as the line names it (`d$v`).

- label:

  The variable's label, or NA or NULL.

## Value

Character: the line, indented two spaces; none when there is no label.
