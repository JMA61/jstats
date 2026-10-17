# Internal helper: a call forwarded through a wrapper's `...`, as typed

`.wrap <- function(...) jplot(...)`: inside jplot()'s generic,
[`match.call()`](https://rdrr.io/r/base/match.call.html) gives every
argument the wrapper forwarded as `..1`, `..2`, names that point at the
wrapper's promises. Until Session 369 (Fix Slate 16) the generic passed
those names on, so jplot.default read them in its own terms:
`.wrap(data = h, Scor)` said "the ..1 data frame", `.wrap(Score)` under
a juse() default stopped on a variable named "..1", and
`.wrap(data = h, Score)` with a separate `Score` in the workspace
stopped on rlang's error, the generic having forced the promise. Each
`..N` is replaced here by the expression it forwards, read from the
argument's quosure, which carries the environment the expression was
typed in.

## Usage

``` r
.jst_forwarded_args(mc, q_x, q_which, q_dots, caller_env)
```

## Arguments

- mc:

  The generic's `match.call(expand.dots = TRUE)`.

- q_x, q_which:

  The quosures of `x` and `which`, or NULL where the call does not give
  them.

- q_dots:

  The dots' quosures, `rlang::enquos(...)`.

- caller_env:

  The environment the call was made from.

## Value

A list: `names`, the arguments' names ("" where unnamed); `typed`, the
arguments with each `..N` replaced by the expression it forwards (for
messages); `args` and `env`, what to evaluate and where; `forwarded`,
whether any argument was forwarded; `mixed`, whether the arguments came
from more than one environment.

## Details

The direct call has no `..N` and comes back unchanged, to be evaluated
where it was made. A forwarded call is evaluated where the forwarded
expressions were typed, as the direct call would be – but only when
every argument that needs an environment shares that one. A wrapper that
passes an object of its own beside the forwarded ones
(`function(dat, ...) jplot(data = dat, ...)`) mixes two, and its
arguments keep their `..N` (`mixed`); the generic then passes a forced
`x` as its quosure.

The quosures are taken in the generic's own frame, before anything
forces an argument, and matched here to the call's arguments: `x` and
`which` by name, the rest in order to the dots'. When the counts
disagree, none is used and the call comes back unchanged.
