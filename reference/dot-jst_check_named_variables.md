# Internal helper: catch a named item in a variable list

A variable list (the `...` of
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md),
[`jsum()`](https://jma61.github.io/jstats/reference/jsum.md),
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) and
the rest) takes unquoted names only; nothing reads the names of that
list, so a NAMED item is always a mistake. Two mistakes arrive this way,
and the name tells them apart (Session 290):

- the name is a column of the frame: a condition typed with a single
  `=`, `jdesc(community, Age, Gender = 1)`, where R's parser has already
  turned `Gender = 1` into an argument named Gender. Before Session 290
  the value was looked up as a variable ("Variable(s) not found in
  community: 1."), and
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md),
  which had no `...`, died inside R ("unused argument (Gender = 1)").
  The error now shows the fix in the form the caller can take:
  `jsubset(Gender == 1)` for
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md);
  `subset = Gender == 1` where the caller has a `subset` input (read
  from the caller's own formals, so the functions that do are never
  listed by hand); "list the variable on its own" otherwise.

- the name is not a column: a misspelled input that R could not
  partial-match (formals after `...` match exactly),
  `jdesc(community, Age, digit = 2)`. Routed to
  [`.jst_check_args()`](https://jma61.github.io/jstats/reference/dot-jst_check_args.md)
  for its "unused input(s)" message. Unnamed items pass through
  untouched. Called at every `rlang::enquos(...)` site directly after
  the capture, and from
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  before its argument grammar runs.

## Usage

``` r
.jst_check_named_variables(quos, data, fn_name)
```

## Arguments

- quos:

  The captured variable list (`rlang::enquos(...)`).

- data:

  The resolved data frame, or `NULL` when no frame is in hand
  ([`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  calls before resolving one); then every named item is treated as a
  condition.

- fn_name:

  Character. The calling function's name, for the message prefix and for
  the [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  fix form.
