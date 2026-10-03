# Internal helper: evaluate a filter and refuse one that cannot select rows

The one place a user's filter is run:
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)'s
set-time dry run (origin `"set"`), a per-call `subset =` (`"call"`) and
a stored
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
filter applied at analysis time (`"stored"`), the last two through
[`.jst_apply_mask()`](https://jma61.github.io/jstats/reference/dot-jst_apply_mask.md).
Every failure STOPS (Session 330). Until then an evaluation failure was
swallowed at set time – `jsubset(d, Agee > 30)` reported "activated" –
and warned at analysis time, after which the analysis ran on every row
with a Case Processing row reading "jsubset() 0": ordinary-looking
output for the wrong sample, identically on every call. In order:

1.  The evaluation. On an error: a workspace vector the condition would
    recycle
    ([`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md);
    a labelled variable refuses the comparison where a plain one
    recycles), then a name found nowhere
    ([`.jst_filter_unbound()`](https://jma61.github.io/jstats/reference/dot-jst_filter_unbound.md)),
    then any other reason, which relays R's message and claims nothing
    more. Warnings from the evaluation are held rather than caught – a
    handler that caught them would abandon the evaluation and skip the
    checks below – and are given back only when the filter passes, so
    R's "longer object length" warning never prints ahead of the stop
    that explains it. At set time they are dropped, with any message, as
    they always were.

2.  The shape of the result
    ([`.jst_check_mask_shape()`](https://jma61.github.io/jstats/reference/dot-jst_check_mask_shape.md)).
    It comes before the recycling check so that a filter built from a
    workspace object alone (`keep3 == TRUE`, three values for twelve
    rows) keeps the shape error and its fix.

3.  A workspace vector recycled against the data, which leaves a result
    of the right shape: silently when the row count divides by its
    length.

The three origins differ in wording only. What was typed in this call is
the subject of its message (Rule AD): the condition at set time, with
the "earlier filter is unchanged" line when there is one; `subset = `
and the condition per call. A stored filter was accepted when set, so
its message names the frame and the filter, says it "cannot be applied",
and ends on both exits – set aside (`off`), delete (`NULL`) – as the
stored shape error does: it re-runs on every analysis of that frame
until dealt with. A name found nowhere "was not found" at set time and
"no longer exists" for a stored filter, which the set-time check makes
true. The per-call evaluation message is the one it has always been.

## Usage

``` r
.jst_filter_mask(
  expr,
  expr_str,
  data,
  envir,
  origin = c("set", "call", "stored"),
  data_name = NULL,
  named_frame = FALSE,
  prior = FALSE,
  n_frame = NULL
)
```

## Arguments

- expr:

  The unevaluated filter (a language object).

- expr_str:

  Character. The filter as typed.

- data:

  Data frame to evaluate it against.

- envir:

  Environment the filter's other names resolve in.

- origin:

  One of `"set"`, `"call"`, `"stored"`.

- data_name:

  Character. The data frame's name.

- named_frame:

  Logical. For `"set"`: the user named the frame in the call; when FALSE
  the not-found message adds the juse() default hint
  [`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md)
  gives.

- prior:

  Logical. For `"set"`: an earlier filter exists for the frame; the
  message says it is unchanged.

- n_frame:

  Integer or NULL. For `"call"`: the frame's row count before the
  pipeline's filters, which tells the recycling stop's two forms apart.

## Value

The evaluated filter: one TRUE, FALSE or NA for every row.
