# Internal helper: stop on infinite values an analysis cannot use

Session 394 (Fix Slate 30; the (S392) infinite-value item, on the lean
Jeff okayed: "Yes to everything."). A variable holding Inf or -Inf –
what [`log()`](https://rdrr.io/r/base/Log.html) of a zero gives, or a
division by zero – reached the analyses as a number:
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) stopped on R's
"missing value where TRUE/FALSE needed" with no `jt():` in front;
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md),
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
on [`lm.fit()`](https://rdrr.io/r/stats/lmfit.html)'s "NA/NaN/Inf in
'y'" ([`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) after
a Group Descriptives row reading Inf);
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) printed r
= NaN; [`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md)
printed a blank alpha under a warning naming items "NA, NA, NA"; and
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md) drew a
histogram without a case its N line counted, under ggplot2's "Removed 1
rows" warning. One stop now, under the Case Processing block (in
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md), under
the N line), naming each variable and its count of infinite values among
the cases the analysis uses.

## Usage

``` r
.jst_stop_infinite(
  data,
  vars,
  data_name = NULL,
  what = "this analysis cannot use"
)
```

## Arguments

- data:

  The cases the analysis uses (a data frame).

- vars:

  Character; the variables to check. A variable that is not stored as
  double (a factor, text, integers) cannot hold an infinite value and is
  skipped.

- data_name:

  Character or NULL; the data frame's name.

- what:

  Character(1); the end of the first sentence.

## Value

Invisibly `NULL` when no variable holds an infinite value; otherwise
never returns.

## Details

jstats does not make the values missing on its own, as it never assumes
a blank text cell is missing (Session 340): the stop gives the line that
does it in a new variable (voice Rule G's R suffix) and the call run on
that variable. A computed term in a formula is different: jstats
computed it, and a value that became infinite is set to missing with a
note (AUDIT-024,
[`.jst_resolve_formula_transforms()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_formula_transforms.md)),
so it never reaches this stop. Spearman's and Kendall's correlations
rank the values and can use them, so
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) calls
this for Pearson's only.

The lines are given when the data frame's name can be typed, as ruling
R19's stop gives its add-it lines
([`.jst_frame_object_text()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object_text.md));
the call, when the user's call is in hand
([`.jst_caller_call()`](https://jma61.github.io/jstats/reference/dot-jst_caller_call.md)),
each variable swapped for its new one wherever the call names it, bare
or in quotes, never in a function's place.
