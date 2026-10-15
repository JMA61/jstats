# Internal helper: the call as typed, with one argument replaced

Rebuilds `cl` (the call as typed) with the argument `arg` – found by
name when the user named it, else by its matched expression among the
positional items – replaced by `new`, and returns the one-line text.
Used by
[`.jst_word_args()`](https://jma61.github.io/jstats/reference/dot-jst_word_args.md);
the layout is the wrapper layer's.

## Usage

``` r
.jst_call_with(cl, mc, arg, new, name_it = FALSE)
```

## Arguments

- cl:

  The call as typed.

- mc:

  The matched call.

- arg:

  Character(1); the argument's name.

- new:

  The replacement (a string, or a call).

- name_it:

  Logical; name a positional argument in the rebuilt call.

## Value

Character(1).
