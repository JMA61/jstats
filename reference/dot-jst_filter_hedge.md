# Internal helper: the line that points at the filters, hedged

For a variable left with one value when no filter names it: the filters
may be the cause, so the line asks the user to check them. Only when a
filter excluded cases from this analysis (the S338 item: a stop that
guessed at
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) on a
frame with no filter of any kind).

## Usage

``` r
.jst_filter_hedge(sample_info, data_name, what)
```

## Arguments

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- data_name:

  Character(1) or `NULL`.

- what:

  Character(1); what the filters may be excluding ("the other values").

## Value

Character(1) starting with a newline, or `NULL`.
