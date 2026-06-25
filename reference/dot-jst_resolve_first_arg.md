# Internal helper: resolve the first positional argument of a data-first function

Inspects the unevaluated first argument of a data-first function and
decides whether the user passed a real data frame, omitted the data
argument (so the
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
should be used), or passed a bare variable name without a leading comma
(so the default should be used and the captured symbol treated as the
user's first content argument).

## Usage

``` r
.jst_resolve_first_arg(
  data_sub,
  data_missing,
  fn_name,
  envir = parent.frame(),
  allow_null = FALSE,
  accept_vector = FALSE
)
```

## Arguments

- data_sub:

  The substituted first argument, captured by the caller via
  `substitute(data)`.

- data_missing:

  Logical. The result of `missing(data)` in the calling function. Must
  be captured by the caller because
  [`missing()`](https://rdrr.io/r/base/missing.html) cannot be used
  reliably across function call boundaries.

- fn_name:

  Character. The calling function's name, used in tailored error
  messages.

- envir:

  Environment. The calling function's parent frame; used for evaluating
  the first argument and looking up the juse default data frame.

- allow_null:

  Logical. If `TRUE`, literal `NULL` is returned with mode `null` for
  the caller to handle. Defaults to `FALSE`, in which case literal
  `NULL` errors.

- accept_vector:

  Logical. If `TRUE`, an expression that evaluates to a non-data-frame
  value is returned with mode `vector_input` for the caller to handle.
  Defaults to `FALSE`, in which case such inputs are treated as
  bare-symbol variable-name attempts (mode `symbol_with_default`).

## Value

A list with components:

- `mode`:

  Character. One of `default`, `null`, `explicit`, `vector_input`,
  `symbol_with_default`.

- `data`:

  The resolved data frame (or `NULL` for modes `null` and
  `vector_input`).

- `name`:

  Character name string for messages (or `NULL` for modes `null` and
  `vector_input`).

- `first_arg_sub`:

  The user's substituted first argument (or `NULL` when not applicable).
  Set for modes `vector_input` and `symbol_with_default`.

- `first_arg_value`:

  The evaluated value of the first argument, set only for mode
  `vector_input`; `NULL` otherwise.

## Details

Distinguishes five outcomes via the `mode` field:

- `default`:

  Data argument was missing; juse default used.

- `null`:

  User passed literal `NULL`; only returned when `allow_null = TRUE`.
  Caller handles (e.g., for global clear semantics in
  jdummy/jsubset/jcomplete).

- `explicit`:

  User passed an expression that evaluated to a data frame. That data
  frame is used.

- `vector_input`:

  Only returned when `accept_vector = TRUE`. User passed an expression
  that evaluated to a non-data-frame value (typically an atomic vector
  or a column reference like `SampleData$Gender`). The caller handles
  this — usually by wrapping the value in a temporary data frame.

- `symbol_with_default`:

  User passed a bare symbol that did not evaluate (or evaluated to a
  non-data-frame value when `accept_vector = FALSE`). Treated as a
  variable-name attempt missing the leading comma. The juse default is
  used as the data frame, and the caller is expected to inject
  `first_arg_sub` as an additional content argument.

Errors with a tailored message when the user passed something that
cannot be resolved (e.g., bare symbol with no juse default set, or
literal `NULL` when `allow_null = FALSE`).
