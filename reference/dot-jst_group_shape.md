# Internal helper: group sizes and within-group variation of an outcome

What [`jt()`](https://jma61.github.io/jstats/reference/jt.md) and
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) need to
know before they compute anything: how many analysis cases each group
holds, and whether the outcome varies inside it. A group of one case has
no variance, and a group whose cases all hold one value has a variance
of zero; R answers both in its own words ("not enough 'y' observations",
"data are essentially constant"), or with an F of
27815876027865139260134097158144 (Session 346).

## Usage

``` r
.jst_group_shape(y, g)
```

## Arguments

- y:

  Numeric vector; the outcome.

- g:

  Factor; the groups, with no empty level.

## Value

A list: `n` (cases per group, named by level), `flat` (logical per
group: two or more cases, all holding one value), `mean` and `var` (per
group; `var` is `NA` for a group of one case).
