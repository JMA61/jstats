# Internal: jscreen()'s footnote and note for dates stored as text

Session 361 (the S222 item, E3, on its lean): under the Variable Types
table, the as.Date() line for each variable whose Sub-class is "date
(unparsed)" – two lines when its values fit day/month and month/day –
then, for a two-digit year, a consequential note with the range() line
that shows the years as.Date() gives. Since Session 382 a variable with
a label gets, after its line or lines, the line that puts the label back
([`.jst_label_line()`](https://jma61.github.io/jstats/reference/dot-jst_label_line.md)),
since as.Date() drops it.

## Usage

``` r
.jst_date_text_report(date_info, data_name)
```

## Arguments

- date_info:

  Named list of
  [`.jst_date_text_format()`](https://jma61.github.io/jstats/reference/dot-jst_date_text_format.md)
  results, each with the variable's `label` added by jscreen().

- data_name:

  The data frame's name, for the printed lines; one that is not a name
  gives `mydata`.
