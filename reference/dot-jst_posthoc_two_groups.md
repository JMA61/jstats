# Internal helper: the line that stands in for a two-group post-hoc table

With two groups there is one comparison, and the test above it has made
it: a post-hoc table held one row whose p repeated that test's (Tukey
HSD after the traditional ANOVA, Games-Howell after Welch's). No table
is printed and none is returned; one line says why (Session 346; the
S344 item's rider).

## Usage

``` r
.jst_posthoc_two_groups()
```

## Value

Invisibly NULL; called for the line it prints.
