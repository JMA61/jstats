# Internal: each post-hoc pair's two groups, by code and label

jaov()'s post-hoc table (Tukey HSD, or Games-Howell under Welch) names
each pair in its comparison column as two factor levels joined by a
hyphen, "later-earlier", which a label holding a hyphen makes impossible
to split. Both tests list the pairs in one order, that of
[`stats::TukeyHSD()`](https://rdrr.io/r/stats/TukeyHSD.html): the lower
triangle of the groups' matrix column by column, (2, 1), (3, 1), ...,
(3, 2), the difference taken as the first group minus the second. This
adds group1_code, group1_label, group2_code and group2_label in that
order (Session 399, Capability Slate T's build 0), after checking that
the comparison column reads exactly as that order would write it; where
it does not, the four columns are NA rather than a guess.

## Usage

``` r
.jst_posthoc_codes(tbl, gm)
```

## Arguments

- tbl:

  The post-hoc table (comparison, diff, lower, upper, df, p, test).

- gm:

  The groups' rows of the group front's group_map, in level order.

## Value

`tbl` with the four columns added.
