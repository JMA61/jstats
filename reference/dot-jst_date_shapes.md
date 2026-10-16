# Internal: the date shapes jscreen() recognizes in text

Session 361 (the S222 item, E3). Each entry is a pattern every value
must match and the as.Date() format (or two, where day/month and
month/day read alike) that must parse every value. Ordered so that no
earlier pattern matches a later one's values. The month-name forms read
English names, as R's month-name format does in an English locale:
"1-Apr-15", "28NOV2007" (SAS DATE9.), "28NOV07", "1 April 2015", "April
1, 2015".

## Usage

``` r
.jst_date_shapes
```
