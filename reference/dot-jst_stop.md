# Internal helper: signal an error in the package house voice

Concatenates its ... arguments into a message and raises a stop()
prefixed with the user-facing function name as "(): ". The function name
is taken from fn when supplied, otherwise auto-detected from the call
stack via .jst_caller_fn(); if detection fails the message is emitted
without a prefix rather than erroring. Always signals with call. =
FALSE.

## Usage

``` r
.jst_stop(..., fn = NULL)
```

## Arguments

- ...:

  Message parts, concatenated with paste0().

- fn:

  Optional function name (without parentheses); auto-detected when NULL.

## Value

Never returns; always signals an error.

## Details

The assembled message is width-wrapped here via .jst_wrap_message(). The
first-line reserve is nchar(prefix) + 8: the emitter's own "fn(): " tag
plus the widest inline chrome R can attach to the error route – "Error :
" under try() is 8 columns; the top-level "Error: " is 7. Reserving the
wider form means the RENDERED first line fits the message width in every
R configuration, not just the console default. Policy (Session 256):
each emitter reserves the widest inline prefix R can attach to its route
– stop 8 plus the fn tag, warn 9, msg / msg_out 0. Builders must not
wrap their own prose ahead of this emitter (receive_package()'s
structural gate refuses the file): only the emitter knows the real
prefix and chrome, so only its reserve can be correct rather than
guessed.
