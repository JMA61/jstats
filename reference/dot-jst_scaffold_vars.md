# Internal helper: the variables shown in a reassignment line

The text that stands for a call's variables in the durability note's two
lines, each of which ends in the template's own `...` and is never
wrapped (voice Rule L). A call on many variables once put every name on
both lines: 52 names made two lines of some 1,300 characters (the S298
item, with S292 site 1; Session 339). Three forms, the first that
applies: `vars =` as the call typed it, when the call gave it and it
fits the line; every name, when there are three or fewer and they fit;
otherwise nothing, so the line reads `d <- jdeclare_missing(d, ...)` and
the template's `...` stands for all of the call's arguments (voice Rule
K). A list is never shown in part: a line naming the first few of
fourteen variables, completed and run, would declare on those few (the
concern modify_form_walk.R Section 10 has recorded since S282).

## Usage

``` r
.jst_scaffold_vars(
  var_names,
  vars_typed = NULL,
  fixed_chars = 0L,
  width = .jst_resolve_width()
)
```

## Arguments

- var_names:

  Character; the call's resolved variable names.

- vars_typed:

  Character(1) or `NULL`; the `vars =` argument as typed, when the call
  used it.

- fixed_chars:

  Integer; the characters of the longer line apart from the variables.

- width:

  The message width in force.

## Value

Character(1); `""` when the variables are left to the template's `...`.
