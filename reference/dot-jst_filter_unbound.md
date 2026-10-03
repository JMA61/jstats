# Internal helper: the names a filter reads that are found nowhere

When a filter's evaluation stops, this says whether the reason is a name
that is neither a variable of the data nor an object the caller can see:
a misspelled variable when the filter is set, or a variable or workspace
object removed since, when a stored filter is applied (Session 330). The
names come from
[`.jst_expr_symbols()`](https://jma61.github.io/jstats/reference/dot-jst_expr_symbols.md),
so a function's name, the component after a dollar sign and the body of
an inline function are not candidates. R's own message is consulted for
one thing only: at least one candidate must appear in it between
quotation marks – any character that is not a space and could not be
part of a name. R names the first missing object that way in every
language it is translated into, so the test does not depend on the
wording, and it keeps the claim true when the evaluation stopped for
another reason while a name that was never looked up (inside
[`with()`](https://rdrr.io/r/base/with.html), say) happens to be
unbound. Requiring the marks keeps a one-letter name from matching a
word of the message.

## Usage

``` r
.jst_filter_unbound(expr, data, envir, r_msg)
```

## Arguments

- expr:

  The unevaluated filter.

- data:

  The data frame it was evaluated against.

- envir:

  The environment its other names resolve in.

- r_msg:

  Character; R's message from the failed evaluation.

## Value

Character vector of the names found nowhere, in the order typed; empty
when the failure is not a missing name.
