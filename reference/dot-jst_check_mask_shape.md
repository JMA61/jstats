# Internal helper: refuse a filter result of the wrong shape

A filter must give exactly one TRUE or FALSE (NA allowed) for every row
of the data frame it is applied to. Anything else – a single value,
numbers, text, an empty result, or the wrong number of values – cannot
select rows and is refused with a guided error. ALWAYS stops: a
wrong-shaped result is deterministic (it fails identically on every
call), so there is no warn-and-continue variant, whatever the caller's
`on_error` says (Session 288, decision 1). Refusing a single value is
deliberate: TRUE / FALSE / T / F would mean "keep every row", but a
single value is also the shape of `mean(Score) > 5`, `any(...)` and
`nrow(...)` inside a filter – a likely error reaching for a per-row
comparison – and allowing scalars would make that whole family silently
keep every row (decision 2). A numeric result is refused for the same
reason in the other direction: base R reads a numeric mask as ROW
POSITIONS, so `subset = Keep01` on a 0/1 column analyzed row 1 once per
1 and reported it with a case-processing table that added up (the
Session 289 workstation reproduction).

## Usage

``` r
.jst_check_mask_shape(
  mask,
  n_rows,
  expr,
  expr_str,
  origin,
  data_name = NULL,
  named_frame = FALSE,
  prior = FALSE
)
```

## Arguments

- mask:

  The evaluated filter result.

- n_rows:

  Integer. Row count of the data frame the result must match.

- expr:

  The unevaluated filter (a language object). A bare name that gave
  numbers builds its own fix (`Keep01` -\> `Keep01 == 1`).

- expr_str:

  Character. The deparsed filter, echoed as the subject of the message's
  first line (that echo is what locates the call in a sourced script,
  where `call. = FALSE` shows no call).

- origin:

  One of `"set"`, `"call"`, `"stored"`.

- data_name:

  Character. The data frame's name. Required for `"stored"` (the exits
  are built from it); used by `"set"` to name the frame in the
  unchanged-filter line and the quoted-keyword fix.

- named_frame:

  Logical. For `"set"`: whether the user named the frame in the call, so
  the quoted-keyword fix echoes that form.

- prior:

  Logical. For `"set"`: an earlier filter exists for the frame; the
  message says it is unchanged.

## Value

`invisible(NULL)` when the result is well-shaped; otherwise stops via
[`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md),
which supplies the "(): " prefix from the call stack (`jsubset` at set
time, the analysis function otherwise).

## Details

Three origins share the check and differ only in wording:

- `"set"`:

  the set-time dry run in
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md).
  The user has just typed the filter, so the fix is a corrected call. A
  quoted keyword (`"null"`, `"off"`, `"on"`) is a reset typed with
  quotes and gets the unquoted form back.

- `"call"`:

  the per-call `subset =` argument. The fix names the analysis function
  that received it.

- `"stored"`:

  a persistent
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  filter applied at analysis time. It was accepted when set and has
  since stopped matching the data (an object it depends on changed, or
  the frame gained or lost rows), and it re-runs on every analysis of
  that frame until dealt with – so the fix is BOTH exits, each naming
  the frame: set aside (off, which keeps the text) first, delete (NULL)
  second.
