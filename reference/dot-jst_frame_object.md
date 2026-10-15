# Internal helper: a workspace object standing in for a variable

Ruling R19 (Jeff, Session 356; built Session 357): jstats analyzes the
variables of a data frame. A workspace object holding one value per case
– per row of the frame as given, or per case left after filtering – that
a computed term or a filter condition reads is a variable kept outside
its frame, read past the frame's declared missing values and its stored
filters, and it stops
([`.jst_frame_object_text()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object_text.md)).
It replaces the Session 324 acceptance of such a vector in a computed
term and the Session 331 add-it line, given only when a filter had cut
the frame. A third deliberate departure from
[`lm()`](https://rdrr.io/r/stats/lm.html) parity, after the Session 322
`d$x` refusal and the Session 324 recycling stop.

## Usage

``` r
.jst_frame_object(terms, data, enclos, n_frame = NULL, bare = FALSE)
```

## Arguments

- terms:

  A list of language objects: a formula's computed terms, or one filter
  condition.

- data:

  The data frame the expressions are evaluated against.

- enclos:

  The environment their other names resolve in.

- n_frame:

  Integer or NULL; the frame's row count as given. NULL is read as
  `nrow(data)`.

- bare:

  Logical; visit a bare name given as a whole term (TRUE for a
  condition).

## Value

NULL, or a list of `term` and `operand` (language) and `n` (the object's
number of values).

## Details

A VALUE stays read as [`lm()`](https://rdrr.io/r/stats/lm.html) reads it
(Session 322): an object of one value; any length to the right of `%in%`
or as the table of [`match()`](https://rdrr.io/r/base/match.html); the
table of a lookup indexed by an expression (`w[Group]`); the argument of
a summary (`mean(w)`, `max(w)`), the same as a cutoff computed first. An
object of any other length passes here; combined value by value, the
recycling stop
([`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md))
has it. An object reached with `$`, `@` or `[[` by a literal
(`.GlobalEnv$G`, `lst$G`, `e[["G"]]`) is judged as one; a data frame's
column reached that way was refused before this runs
([`.jst_check_formula_frames()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_frames.md)).
A bare term of a formula is never read from the workspace (Session 322)
and is not visited; in a condition a bare name is. Operands are looked
up, never run, so the check draws no random number and runs no call
twice.
