# Internal: jnumeric()'s, jcount()'s and jlikert()'s one front

The three registration verbs were one body three times over (Session
386, the twin build), differing only in the kind registered, the
function's name and the no-variables example. Each verb passes its
captures as typed – missing(data), substitute(data), ...length(), the
dots' expressions, rlang::enquos(...), parent.frame() and sys.call() –
and each is read here where the verb read it. jdummy() keeps its own.

## Usage

``` r
.jst_register_front(
  kind,
  fn,
  example,
  data_missing,
  data_sub,
  dots_n,
  dots_subs,
  quos,
  remove,
  clear.all,
  envir,
  call,
  fun
)
```

## Arguments

- kind:

  "numeric", "count" or "likert".

- fn:

  Character(1): the verb's name.

- example:

  Character(1): the no-variables stop's example line.

- data_missing, data_sub:

  missing(data) and substitute(data).

- dots_n, dots_subs:

  ...length() and the dots' expressions.

- quos:

  rlang::enquos(...).

- remove, clear.all:

  The call's arguments.

- envir, call, fun:

  parent.frame(), sys.call() and sys.function().

## Value

As the verb returns.
