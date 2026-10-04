# Internal helper: refuse more than one condition in jsubset()

[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) takes
one condition. A second one after a comma – the habit of a filter
function that takes several – was dropped without a word when the
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
supplied the data frame: `jsubset(Age < 40, Sex == 1)` stored `Age < 40`
and reported it "activated" (Session 334). The stop names the conditions
and gives the joined call; a condition whose own top-level operator is
`|` is parenthesized there, since `&` binds more tightly.

## Usage

``` r
.jst_one_condition_stop(conds, frame = NULL)
```

## Arguments

- conds:

  A list of unevaluated conditions, two or more.

- frame:

  Character(1) or `NULL`; the data frame as typed, when the call named
  one.

## Value

Does not return; stops.
