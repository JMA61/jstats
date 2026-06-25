# Internal helper: count-variable classifier

Returns TRUE when a variable's values fit the structural pattern of a
small-range count: non-negative whole numbers in the 0-6 range, with no
value labels attached, and not a dichotomy (which has its own helper).

## Usage

``` r
.jst_is_count(x, var_name = NULL, data_name = NULL, override = NULL)
```

## Arguments

- x:

  A variable (vector).

- var_name:

  Optional variable name (with `data_name`) used to consult a
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)
  registration.

- data_name:

  Optional data-frame name (with `var_name`) used to consult a
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)
  registration.

- override:

  Optional per-call asserted role; `"count"` forces TRUE (the per-call
  counterpart of a
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)
  registration).

## Value

TRUE if the variable is an asserted count, or looks like a small-range
count structurally; FALSE otherwise.

## Details

Used as a *warning trigger* for analyses that assume a continuous DV
with at least 6-7 distinct values for reliable inference. The jlm DV
check uses it to warn that linear regression's assumptions (normally
distributed residuals, constant variance) are usually violated by
small-range counts. A future jpoisson()/jnegbin() workflow would be the
appropriate response when count regression is implemented; for now the
warning explains the limitation.

This helper deliberately uses the same range rules as
.jst_is_discrete_integer() (min \>= 0, max \<= 6, all whole numbers).
The only structural difference is the "not haven-labelled" rule: counts
in this package are typically plain integers, while labelled small-range
integers are usually Likert items or category codes rather than counts.
Both helpers can return TRUE for the same variable (e.g., an unlabelled
small-range count fires both); the calling function decides how to
handle that overlap. For example, the jlm DV check examines counts
before discrete-integers so that an unlabelled count gets the
count-specific warning rather than the more general categorical-like
one.

Detection criteria, all required:

- is.numeric and not haven_labelled

- not a dichotomy (.jst_is_dichotomy() handles the binary case)

- all values are whole numbers (integer-valued)

- minimum value \>= 0

- maximum value \<= 6

- at least 2 non-NA values

Registered intent overrides the structural rules ("Rule A"). When the
variable has been registered as a count via
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md), or a
per-call `override = "count"` is supplied, this helper returns TRUE
regardless of the structural range checks, so a conceptual count outside
the 0-6 band (e.g. a 0-30 victimization tally a user has declared a
count) still routes to the count branch. Identity (`var_name` +
`data_name`) is required to consult the registration; without it the
helper is purely structural, as before.
