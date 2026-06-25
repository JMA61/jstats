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
