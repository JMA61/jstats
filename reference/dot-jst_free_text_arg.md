# Internal helper: a free-text slot typed without its quotes

Ruling R18 (Session 356): a file name, a sheet name, a folder, the name
a loaded data frame is given, all go in quotes. A bare symbol in such a
slot that resolves to nothing – `jload("f.rds", name = mydata)`,
`joptions(data.dir = Data)` – met R's "object 'Data' not found"; it gets
jload()'s form, the call as typed with the word quoted. A symbol that
resolves is a name holding the value and is left alone, as is any other
expression. The check reads the unevaluated argument, so it runs before
the slot is forced.

## Usage

``` r
.jst_free_text_arg(sub, env, cl, mc, arg, noun, fn)
```

## Arguments

- sub:

  The argument as typed (`substitute(arg)`).

- env:

  The caller's environment.

- cl, mc:

  The call as typed and the matched call.

- arg:

  Character(1); the argument's name.

- noun:

  Character(1); what the slot takes ("a file name").

- fn:

  Character(1); the user-facing function's name.

## Value

Invisible NULL; stops on a bare word that resolves to nothing.
