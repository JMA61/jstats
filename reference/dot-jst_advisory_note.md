# Internal helper: emit a default-silent advisory note

Advisory notes are pure FYI: the function did exactly what was asked,
and the note just reports a benign detail (a no-op recode, a silent
text-to- numeric coercion). They are shown only at `joutput("full")` and
stay hidden at "standard" and "minimal". Consequential notes – an
overwrite, an override taking precedence, a skipped variable, a
diagnostic that could not be computed – use a plain
[`message()`](https://rdrr.io/r/base/message.html) instead and are
always visible.

## Usage

``` r
.jst_advisory_note(...)
```

## Arguments

- ...:

  Parts of the message, passed through to
  [`message()`](https://rdrr.io/r/base/message.html).

## Value

Invisibly NULL.

## Details

This is the tier-gating primitive for the note layer; a broader joutput
note-gating framework would build on it.
