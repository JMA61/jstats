# Internal helper: build a persistence/durability note

Returns the standardized "where does this state live, and how do you
make it last" note shared by every state-setting verb. The note states
which durability rung the just-applied state reached and the action to
climb to the next rung. The mechanics deliberately differ by verb – the
registry verbs (jnumeric, jcount, jlikert, jdummy) annotate the session
through a notebook, while jdeclare_missing writes a missing-value
declaration onto the data frame – so the rung argument selects the
wording rather than the helper inferring it.

## Usage

``` r
.jst_durability_note(
  rung,
  data_name,
  count = NULL,
  verb = NULL,
  var_name = NULL,
  modify = FALSE,
  data_kind = "name"
)
```

## Arguments

- rung:

  One of `"session"` (registry registrations – jnumeric, jcount,
  jlikert, jdummy), `"frame"` (a UDM declaration – jdeclare_missing), or
  `"convert"` (a missing-value conversion – jconvert).

- data_name:

  Character string name of the data frame, used to build the jsave()
  example and, for the "frame" rung, the reassignment line.

- count:

  Integer number of registrations just set ("session" rung only);
  controls singular/plural agreement. Unspecified or not equal to 1
  yields the plural form.

- verb:

  Character string name of the calling verb ("frame" rung only), used to
  build the reassignment line.

- var_name:

  Character string ("frame" rung only) placed where the call's variables
  go in the reassignment line: one variable name, or what
  [`.jst_scaffold_vars()`](https://jma61.github.io/jstats/reference/dot-jst_scaffold_vars.md)
  returns for a call on several, which is `""` when the line's own `...`
  is to stand for them.

- modify:

  Logical. `TRUE` when the call wrote its result back (`modify = TRUE`);
  the "frame" and "convert" rungs then give the save tip in place of the
  reassignment lines.

- data_kind:

  What the call's data argument was, as
  [`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)
  reads it ("frame" and "convert" rungs). `"name"`, the default: a data
  frame's name or the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default,
  which gets both the reassignment line and the `modify = TRUE` line.
  `"place"`: somewhere a result can be assigned that is not a plain name
  (`lst$d`), which gets the reassignment line alone, because
  `modify = TRUE` needs a name. `"expression"`: anything else (`mk()`),
  which gets a line assigning the result to a new name. Until Session
  339 the scaffold read `mk() <- jconvert(mk(), ...)`, which does not
  run (the S219 item, finding 2).

## Details

Returns the note as a single string with NO trailing newline. The
"session" rung carries a "Note:" prefix; the "frame" rung follows
jdeclare_missing's declaration block, so it has none. Callers emit it
however they already do: the registry verbs message() it;
jdeclare_missing appends it to its larger notification string.
Visibility (standard and full, suppressed at minimal) is the caller's
gate, not this helper's.

One deliberate divergence between the two rungs: the "session" rung
names "R format (.rds)" because registry registrations bake only into
.rds, while the "frame" rung says generic "save the data frame" because
UDM codes also survive .sav and .dta, so naming .rds there would be a
false constraint.
