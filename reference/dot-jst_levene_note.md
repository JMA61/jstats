# Internal helper: the note under a significant Levene's test

Printed by [`jt()`](https://jma61.github.io/jstats/reference/jt.md) and
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) under the
Levene table when the test is significant and the test run assumes equal
variances. Three forms (Jeff's ruling, Session 346, replacing ruling R14
part 1). The first two lines are the same in each and state the facts
the reader needs to judge for themselves: the ratio of the largest group
to the smallest, and of the largest standard deviation to the smallest.
The verdict that follows is graded, because the textbooks do not agree
on a cutoff (Stevens: group sizes within 1.5; Moore, McCabe and Craig:
the largest SD less than twice the smallest; Howell: a variance ratio of
four, with unequal sizes "not mixing" with it):

- sizes within 1.25 AND SDs within 2: "usually still acceptable";

- sizes beyond 1.5 AND SDs beyond 2: the p-value "may not be reliable";

- anything between: "guidelines differ".

The 1.25 is from simulation, not from a text: inside it the standard
test's rejection rate under a true null stayed at or under about 7.5
percent at a nominal 5. The wording does not say which way the p-value
errs, because that depends on which groups are the more variable.

## Usage

``` r
.jst_levene_note(p, y, g, fn)
```

## Arguments

- p:

  The Levene test's p-value.

- y:

  Numeric vector; the outcome.

- g:

  Factor; the groups.

- fn:

  Character(1); `"jt"` or `"jaov"`.

## Value

Invisibly NULL; called for the note it prints.

## Details

Until v0.9.219 there were two forms and one test, the group sizes within
1.5, under which the note said the standard test "remains appropriate"
for clinic's ScreenTime by Condition, whose smallest group has more than
twice the smallest SD (the S344 item).

Not printed at the minimal level
([`.jst_notes_on()`](https://jma61.github.io/jstats/reference/dot-jst_notes_on.md)),
nor when a group has fewer than two cases, which leaves no SD to
compare.
