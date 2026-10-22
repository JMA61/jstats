# Internal helper: full-width punctuation in a map or labels string

Session 390 (the non-English probe; lean L2): a Chinese, Japanese or
Korean input method types the full-width semicolon, equals sign and
comma, which look like the plain ones and are other characters. jstats
separates rules with the plain ones only, so
`jrelabel(d, Sex, labels = "1=M<fw;>2=F")` made ONE label reading
"M\<fw;\>2=F" for code 1, jdeclare_missing() kept the first code of two
and gave it the rest as its label, and jrecode() and jencode() stopped
in words that never named the character. This check runs at the front
door of jrecode(), jencode(), jrelabel() and jdeclare_missing(): a
string given to one of `args` (as typed, or held by a name) that holds
one of the three outside a quoted label stops, naming what it found,
with the call retyped with the plain characters – an ideographic space
beside a replaced semicolon made a plain space too, since the parser's
trim does not remove it. A label in quotes (ruling R17: the mark right
after its =) is the user's text and is left alone, so a label that holds
a full-width semicolon is still possible.

## Usage

``` r
.jst_fullwidth_args(cl, mc, env, args, fn)
```

## Arguments

- cl:

  The call as typed
  ([`sys.call()`](https://rdrr.io/r/base/sys.parent.html)).

- mc:

  The matched call (`match.call(expand.dots = TRUE)`).

- env:

  The caller's environment, where a name is looked up.

- args:

  The arguments to read, e.g. `c("map", "labels")`.

- fn:

  Character(1); the user-facing function's name.

## Value

Invisible NULL; stops when full-width punctuation is found.
