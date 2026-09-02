# Internal helper: build the choose-first gate error family

The one builder behind every render of the Decision 11 choose-first gate
(step (4) decided INERT at S240; texts approved S243; built S244), so
the variants cannot drift apart. Renders are STATELESS (identical at
every firing), single fixed form across joutput tiers, and governed by
Rule V: real choices as copy-pasteable lines, each with a one-line
consequence, the recommendation carried in the menu copy (stata, for
base-R/AI mixing), and the permanence line stating the action itself.

## Usage

``` r
.jst_choose_convention_error(
  variant,
  fn,
  head_tail = NULL,
  conv = NULL,
  fits = NULL,
  data_name = NULL,
  var_names = NULL,
  range = NULL,
  over_var = NULL,
  over_n = NULL,
  prefixed = TRUE
)
```

## Arguments

- variant:

  One of `"menu"`, `"pair"`, `"range_unset"`, `"conflict_setting"`,
  `"conflict_call"`.

- fn:

  The exported caller's name, for the first line's wrap reserve (the
  [`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md)
  prefix length).

- head_tail:

  Menu/pair variants: the clause completing the head.

- conv:

  Conflict variants: the conflicting convention token (`"stata"` or
  `"sas"`) – the per-call value for E, the joptions setting for D; flips
  the style words and the `to =` target mechanically.

- fits:

  Conflict variants: TRUE when every targeted column's range covers 26
  or fewer values (the jconvert cap), so the two-step recipe is honest
  to paste.

- data_name, var_names, range:

  Conflict variants: the echo pieces for the recipe lines (`range`
  already sorted).

- over_var, over_n:

  Conflict over-cap render: the first targeted column over the cap, and
  its in-band value count.

- prefixed:

  TRUE (default) when the body will be passed to
  [`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md),
  which prepends "(): " – the head reserves that width and reads on from
  the prefix. FALSE for a
  [`message()`](https://rdrr.io/r/base/message.html) caller, where no
  prefix is prepended: the head capitalizes and wraps at full width.
  Only the head is affected; every other line is identical, so the two
  paths share one copy of the menu.

## Value

Character scalar: the complete message body (no fn prefix).

## Details

Variants (the S243 approved-text sheet, changelog SESSION 243 (g)):

- `"menu"`:

  A – the full three-option menu (stata recommended, spss contrastive,
  sas brief), for acts legal under all three conventions: numeric-codes
  declarations and the `missing` token family. `head_tail` completes the
  head ("no missing-value convention is selected, so ").

- `"pair"`:

  B – the stata/sas pair (the spss option line omitted), for literal
  tagged spellings, which the paste-and-rerun test fails under spss.

- `"range_unset"`:

  C – the never-set range variant: single per-call fix line
  (`convention = "spss"`); its user has no convention to stay in, so no
  menu and no recipe.

- `"conflict_setting"` / `"conflict_call"`:

  D / E – the range-vs-tagged-convention conflicts (setting-level and
  per-call), DATA-AWARE with two renders: when every targeted column's
  range covers 26 or fewer values (`fits`), the two-step stay-tagged
  recipe (declare the range under SPSS convention, then
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)),
  each recipe line preceded by what it does; over the cap, the count
  line, the SPSS remedy, and the Rule X requirement sentence. Only the
  head differs between D and E (and E's "use" versus D's "stay in": E's
  user may hold no setting), so one code path emits all four renders.

Recipes echo the caller's actual data-frame name, variables, and range
bounds, in the data, variable(s), named-options teaching form with flat
`modify = TRUE`; runnable lines are bare Rule L lines (2-space indent,
never width-wrapped). Prose is Rule U wrapped; menu consequence lines
wrap at their own indent via
[`.jst_wrap_indent()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_indent.md).
