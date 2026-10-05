# Internal helper: the "after applying ..." part of a group-count stop

[`jt()`](https://jma61.github.io/jstats/reference/jt.md),
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) and
[`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
stop when a grouping variable is left with too few categories. When a
stored
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
or [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
setting is active for the data frame the stop says so, since a setting
that excludes a group is the likely cause: "'Condition' has 1 category
after applying the jcomplete setting and the jsubset filter (Condition
!= 3)". The settings are named as settings (voice Rule AE), the filter
with its condition in parentheses.

## Usage

``` r
.jst_settings_context(data_name)
```

## Arguments

- data_name:

  Character(1) or `NULL`; the data frame's name.

## Value

Character(1): the phrase with its leading space, or `""` when no stored
setting is active for the data frame.

## Details

Until Session 338 the phrase read "after applying jcomplete and jsubset
(Condition != 3)" – a bare name with a spaced parenthesis, which read as
a malformed call (the S293 rider on the S287 item) – and it was built
only when the data frame came from
[`juse()`](https://jma61.github.io/jstats/reference/juse.md), although a
stored setting applies to its data frame however the call names it: with
the frame named,
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) said "has 1
categories" and suggested
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md).
