# Internal: jsum()'s and javg()'s one worker

jsum() and javg() were one body twice over (Session 386, the twin
build): the first argument resolved, the variables read, the declared
missing values masked, each case's sum or mean computed against
min.valid, the summary line, the assign-or-lose reminder and the label.
The captures – the data argument as typed, whether it was given, the
variables in ..., the calling frame – are made in the function the user
called and passed here; data_sub is read only where jsum() read it,
since it is R's missing-argument marker when the data were left out
under a juse() default (S371).

## Usage

``` r
.jst_row_score(
  what,
  fn,
  data_sub,
  data_missing,
  quos_list,
  envir,
  min.valid,
  fixed,
  var.label,
  example,
  call,
  fun
)
```

## Arguments

- what:

  "sum" or "mean".

- fn:

  Character(1): "jsum" or "javg".

- data_sub:

  The data argument's expression (substitute(data)).

- data_missing:

  Logical(1): missing(data) in the caller.

- quos_list:

  The variables (rlang::enquos(...) in the caller).

- envir:

  The caller's calling frame.

- min.valid, var.label:

  The call's arguments.

- fixed:

  Logical(1): javg()'s fixed denominator (FALSE for jsum()).

- example:

  Character(1): the example line of the two-variables stop.

- call, fun:

  sys.call() and sys.function() of the caller, for the resolver's
  rebuilt lines.

## Value

The new variable, invisibly.
