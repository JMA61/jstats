# Internal helper: a bare word typed where a quoted value goes

Ruling R18 (Session 355; built Session 356): a variable is named without
quotes, and anything that is not a variable – a format, a convention, a
method, a level, a plot name – goes in quotes. A user who types
`jconvert(d, to = stata)` or `jplot(r, which = effects)` meets R's own
lookup of the word: "object 'stata' not found", or, when R finds a
function of that name (`effects`, `lm`, `mean`), an error from deeper in
that has nothing to do with the call. This check runs at the function's
front door, before anything is evaluated, and stops with jload()'s form:
the word, that it is not in quotes, and the call to run.

## Usage

``` r
.jst_word_args(cl, mc, env, specs, fn)
```

## Arguments

- cl:

  The call as typed
  ([`sys.call()`](https://rdrr.io/r/base/sys.parent.html)).

- mc:

  The matched call (`match.call(expand.dots = TRUE)`).

- env:

  The caller's environment, where a symbol is looked up.

- specs:

  A named list, one entry per argument checked: a list with `values`
  (the accepted words, in the spelling the function takes), `noun` (what
  the argument takes, for the sentence: "a format name") and,
  optionally, `name_it = TRUE`; the shared entries come from
  [`.jst_word_specs()`](https://jma61.github.io/jstats/reference/dot-jst_word_spec.md).

- fn:

  Character(1); the user-facing function's name, for the prefix.

## Value

Invisible NULL; stops when a bare word is found.

## Details

It fires on a bare symbol – or a [`c()`](https://rdrr.io/r/base/c.html)
of symbols and strings – that spells one of the argument's own values
(compared without regard to case; the printed line spells the value as
the function takes it) and does not evaluate to a character value. A
name holding a value still works (`fmt <- "stata"; to = fmt`), and a
word that is not one of the values is left to R and to the argument's
own choice error, as before.

The line to run is the call as typed
([`sys.call()`](https://rdrr.io/r/base/sys.parent.html)), with the one
argument quoted: a named argument stays named, a positional one stays in
its place unless its spec says `name_it`, for a function whose first
position is read several ways (`joptions(spss)` is given as
`joptions(missing.convention = "spss")`). The line is built on one line;
the wrapper layer lays it out (ruling R5).
