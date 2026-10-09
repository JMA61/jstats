# Internal helper: stop when no case is left to analyze

The listwise functions –
[`jt()`](https://jma61.github.io/jstats/reference/jt.md),
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md),
[`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md),
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md),
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
and [`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md) –
call this directly after the Case Processing block has printed. With no
case left only
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
had a stop of their own; the others went on to answer "'g3' has 0
categories", R's "grouping factor must have exactly 2 levels" or
"contrasts can be applied only to factors with 2 or more levels", raw
"NaNs produced", and in
[`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md) a
warning that items "NA, NA, NA" were negatively correlated (the S338
item; Session 346). One stop now, ahead of every group count.

## Usage

``` r
.jst_stop_empty_sample(sample_info)
```

## Arguments

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

## Value

Invisibly `NULL` when at least two cases are left; otherwise never
returns.

## Details

The second line says how the cases went, from the counts the block above
it shows: by a filter
([`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md),
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md),
`subset =`), because of missing data on an analysis variable, or both.
It names no table, because at `joutput("minimal")` the block is one
line.

One case left stops the same way (Session 346): none of the six can
analyze one case, and the stop each reached named a variable – "k has
only one value", "'g' has 1 category" – when every variable has one
value in one case and the cause is the case count.
