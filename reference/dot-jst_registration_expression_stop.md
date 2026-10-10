# Internal helper: refuse an expression given as the data to a registration

A registration is stored under its data frame's NAME, so a registration
verb needs one. Given a call or a subset in the data's place –
`jnumeric(mk(), Age)`, `jdummy(d[d$Age > 30, ], Grp)` – the four verbs
stored the registration under the text of the expression, where no later
call could reach it, and printed `jsave(mk(), "mk().rds")` (the S339
item; Session 342, Jeff's lean 1). The stop gives two lines that run:
the expression assigned to a name, and the user's own call on that name.
A place (`lst$d`) is not refused: it works end to end, since
`jscreen(lst$d)` and `jsave(lst$d, ...)` read the same text.

## Usage

``` r
.jst_registration_expression_stop(
  data_sub,
  fn_name,
  cl,
  registering = TRUE,
  noun = "registration",
  then = "register"
)
```

## Arguments

- data_sub:

  The substituted data argument, an expression.

- fn_name:

  Character; the calling verb.

- cl:

  The verb's call, as typed.

- registering:

  Logical; `FALSE` for a call that clears or removes.

- noun:

  Character; what is stored, in the singular, without an article
  (`"registration"`, `"jsubset filter"`, `"jcomplete setting"`).

- then:

  Character; the verb phrase after "then" in the second line.

## Value

Does not return; stops.

## Details

A call that clears or removes (`jdummy(mk(), NULL)`, `remove = TRUE`) is
refused too, with the status call as its remedy: nothing is stored under
an expression, and the registrations the user means are under whatever
name the data frame has.

The two stored settings take the same stop since Session 349 (the S341
item; the lean Jeff okayed at S342): `jsubset(mk(), Age > 30)` printed
"jsubset activated for mk(): Age \> 30", a filter no later call reached
unless it typed `mk()` again. `noun` and `then` carry their words: "a
jsubset filter is stored under its data frame's name" / "Give the data
frame a name first, then set it:".
