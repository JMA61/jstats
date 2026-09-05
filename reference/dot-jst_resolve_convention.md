# Internal helper: resolve the active missing-value convention

Implements Decision 11's four-step precedence rule for determining which
UDM convention (SPSS-form, Stata-form, or SAS-form; Decision 13 added
"sas") applies to a fresh UDM declaration or convention-conditional
recode. RESOLVES OR STOPS: returns `"spss"`, `"stata"`, or `"sas"` when
any of levels 1-3 supplies a convention, and otherwise – level 4, no
convention anywhere – signals the Decision 11 choose-first gate (step
(4) decided INERT at S240; built S244) instead of defaulting. The
package never infers a convention for a minting act; an unset option and
an explicit `"none"` are identical.

## Usage

``` r
.jst_resolve_convention(
  per_call = NULL,
  column_convention = NULL,
  act,
  fn,
  marker = NULL
)
```

## Arguments

- per_call:

  The value of the calling function's `convention` argument (typically
  NULL, "spss", "stata", or "sas"). Validated; other values raise an
  error.

- column_convention:

  Optional. `"spss"`, `"stata"`, `"sas"`, or `NULL` (an `NA` from an
  ambiguous mixed-case column is treated as `NULL`). When non-NULL and
  non-NA, level 1 of the precedence rule applies and the function
  returns this value immediately.
  [`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
  populates this argument from
  [`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
  on the operand column.

- act:

  REQUIRED. The minting act, so the level-4 gate renders the honest
  variant: `"codes"` (numeric-codes declaration, full menu), `"token"`
  (the `missing` target family, full menu), `"tagged"` (literal tagged
  spellings, the stata/sas pair), or `"range"` (the per-call fix line).

- fn:

  REQUIRED. The exported caller's name, passed through to
  [`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md)
  so the gate's prefix names the function the user actually called
  (auto-detection is bypassed deliberately: the stop fires inside a
  shared internal helper).

- marker:

  Optional. For `act = "tagged"`: the first tagged spelling in the
  user's call (e.g. `".a"`, parser-normalized lowercase), echoed in the
  gate's head.

## Value

Single character: `"spss"`, `"stata"`, or `"sas"` – or no return (the
level-4 stop).

## Details

The four levels of the precedence rule, in order:

1.  If the column already carries a UDM convention (na_values metadata
    for SPSS-form; tagged_na markers for Stata-form when lowercase,
    SAS-form when uppercase), match it. Handled at the call site by
    passing a non-NULL value to `column_convention`;
    [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
    does not engage this level because it produces fresh columns. A
    mixed-case tagged column classifies as no convention (Decision 13's
    ambiguous rule) and does not engage this level.

2.  If `per_call` is `"spss"`, `"stata"`, or `"sas"`, use that.

3.  If the `missing.convention` setting in
    [`joptions`](https://jma61.github.io/jstats/reference/joptions.md)
    is `"spss"`, `"stata"`, or `"sas"`, use that.

4.  Else STOP with the act-shaped choose-first guided error, rendered by
    [`.jst_choose_convention_error()`](https://jma61.github.io/jstats/reference/dot-jst_choose_convention_error.md):
    the full three-option menu for numeric codes and the `missing` token
    family, the stata/sas pair for literal tagged spellings, and the
    single `convention = "spss"` fix line for a range. Variants are
    assigned per SPELLING by the paste-and-rerun test (Rule V, S243
    amendment).

All call sites are demand-driven – the resolver runs only when the call
actually mints a missing form – so a never-set user doing ordinary
non-minting work never reaches level 4.
