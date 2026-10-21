# Internal: Levene's test for jt() and jaov(), printed and returned

The test on the absolute deviations from each group's mean, its table
and, when Welch's test is not the one run, the note's verdict
(.jst_levene_note()). jt() and jaov() each held this block (Session 386,
the twin build); jt() runs it for an independent test only.

## Usage

``` r
.jst_levene_block(data, dv_name, group_name, digits_n, welch, fn)
```

## Arguments

- data:

  The analysis copy, the grouping variable a factor.

- dv_name, group_name:

  Character(1): the outcome and the group.

- digits_n:

  Integer(1): the digits setting.

- welch:

  Logical(1): whether Welch's test is the one run.

- fn:

  Character(1): the calling function, for the note.

## Value

list(F, df1, df2, p, note): the result jt() and jaov() return.
