# Internal helper: the vector path's collision with a data frame's variable

Ruling R18 (Session 355; built Session 356), ruling R12's other half.
`jdesc(Age)` with no data frame named and none set – or a default that
has no Age – reads the workspace object Age and says nothing, while a
data frame in the workspace holds the variable the user may have meant.
When the expression read is a name (`Age`, `(Age)`, `.GlobalEnv$Age`)
and a data frame the caller can see has a variable of that name, a note
is attached to the one-column frame the re-call analyzes, and
`.jst_vector_note()` prints it under the title: which object was read,
and the call that reads the variable, naming the one frame that has it,
or MyData when several do. A copy of the column is read as it is: the
frame's stored settings and registrations do not reach a copy. Declined
(Jeff, S355): a scan at load time; a note on every vector analysis.

## Usage

``` r
.jst_vector_collision(wrapped, envir, fn_name)

.jst_vector_note(data)
```

## Arguments

- wrapped:

  The
  [`.jst_vector_frame()`](https://jma61.github.io/jstats/reference/dot-jst_vector_frame.md)
  result.

- envir:

  The caller's environment.

- fn_name:

  Character(1); the user-facing function's name.

- data:

  The data frame the re-call received.

## Value

`wrapped`, its frame carrying the note when one applies.
