# Internal helper: Games-Howell pairwise comparisons

The post-hoc test for Welch's ANOVA (Session 341; the S327 item): every
pair of group means compared without a pooled variance. For groups i and
j the standard error is `sqrt(v_i / n_i + v_j / n_j)` from the two
groups' own variances, the degrees of freedom are Welch-Satterthwaite's
for that pair, and the statistic `|diff| / se * sqrt(2)` is referred to
the studentized range distribution for k groups
([`stats::ptukey()`](https://rdrr.io/r/stats/Tukey.html)), which is what
adjusts for the number of comparisons; the 95 percent interval is
`diff +/- qtukey(.95, k, df) / sqrt(2) * se`. Rows and names follow
[`stats::TukeyHSD()`](https://rdrr.io/r/stats/TukeyHSD.html): pairs in
level order, each named `later-earlier` with the difference taken the
same way, so the two post-hoc tables read alike. Base R has no
Games-Howell function; this needs none beyond stats.

## Usage

``` r
.jst_games_howell(y, g)
```

## Arguments

- y:

  Numeric vector; the outcome on the analysis rows.

- g:

  Factor; the groups, with no empty level.

## Value

A data frame, one row per pair: `comparison`, `diff`, `lower`, `upper`,
`df`, `p` (all unrounded) and `test` ("Games-Howell").

## Details

A pair whose standard error is 0 (both groups constant) has no df, p or
interval: its cells are NA and print blank.
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) stops
before this for a group of one case, which has no variance.
