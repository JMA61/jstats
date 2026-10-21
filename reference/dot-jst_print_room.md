# Internal helper: room for a long message when R prints it

R prints an error at the prompt, and stores a warning for printing, cut
to `getOption("warning.length")` bytes – 1,000 unless the user set
another value, the "Error: " prefix counted – and says nothing about the
cut (Session 387: jsave()'s three-part stop on an expression lost its
closing save line in the RStudio Console). The emitters call this just
before they signal: when the text is longer than the setting allows, the
setting is raised to the text's length in bytes plus 50 (room for R's
own prefix in any language), at most R's ceiling of 8,170, and the old
setting is returned for the emitter to put back as it exits. A setting
already large enough is never touched, so a user's own value is never
lowered, and the setting is not a session option of the package: it is
restored within the call, so it is not in `.jst_session_option_keys`.
Guarded: an emitter must never fail to emit, so any error here means no
change.

## Usage

``` r
.jst_print_room(text)
```

## Arguments

- text:

  Character(1), the message as the condition carries it.

## Value

The list [`options()`](https://rdrr.io/r/base/options.html) returns for
the old setting, to pass back to
[`options()`](https://rdrr.io/r/base/options.html); NULL when nothing
was changed.
