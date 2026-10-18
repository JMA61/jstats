# Internal helper: values typed without quotes in a text variable's codes

Ruling R18's front-door check for jdeclare_missing() on a text variable
(Slate E5): `codes = UNKNOWN` or `codes = c(Refused = REF, "")` – a name
that holds nothing, where a quoted value goes. Read from the unevaluated
argument; a name that holds a value is left alone, as R18 leaves it
everywhere.

## Usage

``` r
.jst_bare_code_words(expr, env)
```

## Arguments

- expr:

  The codes argument as typed (`substitute(codes)`).

- env:

  The caller's environment.

## Value

NULL, or a list of `words` (the names typed bare) and `new` (the
expression with each in quotes).
