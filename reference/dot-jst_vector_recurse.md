# Internal helper: re-call jdesc() or jfreq() on a wrapped bare column

The vector-input path's re-call. Every argument the caller received is
forwarded (AUDIT-008: the re-call once passed only some of them, so
digits, subset and case.processing.detail were silently ignored), and
the call is evaluated in a child of the caller's environment, so a
subset condition finds the same objects it would in the data-frame form.
What a single column cannot serve is refused, each time with the
data-frame form as the fix: further variables, a by grouping, and a
subset condition naming another variable. A condition may name the
wrapped variable or an object in the caller's environment. A column
reached through a data frame with the dollar sign
(`subset = d$Keep01 == 1`) was served until Session 323; it is refused
now, with the data-frame form as the fix, because the re-call would read
it from the user's raw frame, past its declared missing values – the
S322 ruling the data-frame form's `subset =` follows.

## Usage

``` r
.jst_vector_recurse(
  fn,
  fn_name,
  wrapped,
  user_env,
  dots = list(),
  subset_sub = NULL,
  by_quo = NULL,
  args = list()
)
```

## Arguments

- fn:

  The calling function, called again.

- fn_name:

  Character: its name, for messages and the re-call.

- wrapped:

  The
  [`.jst_vector_frame()`](https://jma61.github.io/jstats/reference/dot-jst_vector_frame.md)
  result.

- user_env:

  The caller's parent frame.

- dots:

  The caller's `rlang::enquos(...)`; named items have already been
  refused by
  [`.jst_check_named_variables()`](https://jma61.github.io/jstats/reference/dot-jst_check_named_variables.md).

- subset_sub:

  The caller's `substitute(subset)`, or `NULL`.

- by_quo:

  The caller's `rlang::enquo(by)`, or `NULL` for a function without a by
  argument.

- args:

  Named list of the remaining arguments' values.

## Value

The re-call's value.
