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
.jst_registration_expression_stop(data_sub, fn_name, cl, registering = TRUE)
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

## Value

Does not return; stops.

## Details

A call that clears or removes (`jdummy(mk(), NULL)`, `remove = TRUE`) is
refused too, with the status call as its remedy: nothing is stored under
an expression, and the registrations the user means are under whatever
name the data frame has.
