# Internal helper: name an expression before the lines that use it

A message whose runnable lines name `mydata` in place of an expression
given as the data – `jsave(oc86["X"], ...)` – opens each block of those
lines with the assignment that makes mydata, the S339 form (Session 352;
jsave()'s pre-flight refusals, the S351 item). A block is a run of lines
indented two spaces or more; it gets the assignment when one of its
lines names mydata, so a list of variables is left alone and each of
several alternative remedies runs on its own.

## Usage

``` r
.jst_expr_assign_lines(msg, typed)
```

## Arguments

- msg:

  Character(1): the message.

- typed:

  Character(1): the expression as typed.

## Value

Character(1).
