# Internal: jscreen()'s footnote and note for dates stored as text

Session 361 (the S222 item, E3, on its lean): under the Variable Types
table, the as.Date() line for each variable whose Sub-class is "date
(unparsed)" – two lines when its values fit day/month and month/day –
then, for a two-digit year, a consequential note with the range() line
that shows the years as.Date() gives.

## Usage

``` r
.jst_date_text_report(date_info, data_name)
```

## Arguments

- date_info:

  Named list of
  [`.jst_date_text_format()`](https://jma61.github.io/jstats/reference/dot-jst_date_text_format.md)
  results.

- data_name:

  The data frame's name, for the printed lines; one that is not a name
  gives `mydata`.
